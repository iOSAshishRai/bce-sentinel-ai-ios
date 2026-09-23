import json
import logging
import os
from datetime import datetime, timezone
from typing import List

from fastapi import FastAPI, HTTPException
from google import genai
from google.genai import types
from pydantic import BaseModel, Field


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)

logger = logging.getLogger("bce-sentinel-api")


app = FastAPI(
    title="BCE Sentinel AI Backend",
    description="Gemini-powered enterprise incident analysis API",
    version="1.1.0",
)


PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT")
LOCATION = os.environ.get(
    "GOOGLE_CLOUD_LOCATION",
    "global",
)
MODEL_NAME = os.environ.get(
    "GEMINI_MODEL",
    "gemini-2.5-flash",
)


class IncidentRequest(BaseModel):
    id: str
    title: str
    service: str
    severity: str
    message: str


class Evidence(BaseModel):
    title: str
    detail: str


class SimilarIncident(BaseModel):
    id: str
    title: str
    matchPercentage: int = Field(ge=0, le=100)
    resolution: str


class RecommendedAction(BaseModel):
    id: str
    title: str
    description: str
    riskLevel: str
    estimatedRecoveryTime: str


class IncidentAnalysisResponse(BaseModel):
    incidentID: str
    rootCause: str
    confidence: int = Field(ge=0, le=100)
    explanation: str
    evidence: List[Evidence]
    similarIncidents: List[SimilarIncident]
    recommendedAction: RecommendedAction


def create_genai_client() -> genai.Client:
    if not PROJECT_ID:
        raise RuntimeError(
            "GOOGLE_CLOUD_PROJECT environment variable is not configured."
        )

    return genai.Client(
        vertexai=True,
        project=PROJECT_ID,
        location=LOCATION,
    )


def get_historical_incidents() -> list:
    return [
        {
            "id": "INC-1023",
            "title": "Billing database timeout",
            "service": "Billing API",
            "symptoms": (
                "Database request timeouts, elevated API response times, "
                "and increasing active connection count."
            ),
            "rootCause": "Database connection pool exhaustion",
            "resolution": (
                "Restarted the Billing API and reset the database "
                "connection pool."
            ),
        },
        {
            "id": "INC-1132",
            "title": "Connection pool saturation",
            "service": "Billing API",
            "symptoms": (
                "HTTP 503 responses, slow billing requests, and "
                "database connection acquisition failures."
            ),
            "rootCause": "Insufficient Billing API replicas",
            "resolution": (
                "Scaled the Billing API from two replicas to four replicas."
            ),
        },
        {
            "id": "INC-1441",
            "title": "Slow Billing API response",
            "service": "Billing API",
            "symptoms": (
                "Response time exceeded five seconds during periods "
                "of increased transaction volume."
            ),
            "rootCause": "Database connection pool limit was too low",
            "resolution": (
                "Increased the database connection pool limit and "
                "added connection utilization monitoring."
            ),
        },
        {
            "id": "INC-1517",
            "title": "Payment service availability degradation",
            "service": "Payment Service",
            "symptoms": (
                "Intermittent HTTP 503 responses and unhealthy "
                "service instances."
            ),
            "rootCause": "Unhealthy service instance",
            "resolution": (
                "Removed the unhealthy instance and restarted "
                "the payment service."
            ),
        },
        {
            "id": "INC-1632",
            "title": "Activation processing CPU saturation",
            "service": "Activation Service",
            "symptoms": (
                "CPU utilization exceeded 85 percent and activation "
                "processing time increased."
            ),
            "rootCause": "Unexpected processing workload",
            "resolution": (
                "Scaled the activation service and introduced "
                "a processing queue."
            ),
        },
    ]


@app.get("/")
def root():
    return {
        "service": "BCE Sentinel AI Backend",
        "status": "running",
        "version": "1.1.0",
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "projectConfigured": bool(PROJECT_ID),
        "project": PROJECT_ID,
        "location": LOCATION,
        "model": MODEL_NAME,
    }


@app.post(
    "/analyze",
    response_model=IncidentAnalysisResponse,
)
def analyze_incident(
    incident: IncidentRequest,
) -> IncidentAnalysisResponse:
    historical_incidents = get_historical_incidents()

    prompt = f"""
You are BCE Sentinel AI, an enterprise incident-response system.

Analyze the current incident using the supplied historical incidents.
Identify the likely root cause and recommend a safe remediation.

CURRENT INCIDENT:

{incident.model_dump_json(indent=2)}

HISTORICAL INCIDENT KNOWLEDGE:

{json.dumps(historical_incidents, indent=2)}

REQUIREMENTS:

1. Set incidentID to exactly "{incident.id}".
2. Identify the most probable technical root cause.
3. Return a confidence score from 0 through 100.
4. Provide a concise technical explanation.
5. Return exactly three supporting evidence items.
6. Return up to three relevant historical incidents.
7. Every historical incident must include a match percentage.
8. Recommend exactly one low-risk remediation action.
9. Use a machine-readable action ID in snake_case.
10. Use restart_billing_service when a Billing API restart is appropriate.
11. Use low, medium, or high for riskLevel.
12. Set estimatedRecoveryTime to a short human-readable value.
13. This is a controlled hackfest simulation.
14. Do not claim that a real production action has occurred.
15. Return only data conforming to the supplied response schema.
"""

    try:
        logger.info(
            "Analyzing incident %s with model %s in %s",
            incident.id,
            MODEL_NAME,
            LOCATION,
        )

        client = create_genai_client()

        response = client.models.generate_content(
            model=MODEL_NAME,
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.2,
                response_mime_type="application/json",
                response_schema=IncidentAnalysisResponse,
            ),
        )

        if response.parsed is not None:
            if isinstance(
                response.parsed,
                IncidentAnalysisResponse,
            ):
                analysis = response.parsed
            else:
                analysis = IncidentAnalysisResponse.model_validate(
                    response.parsed
                )
        else:
            if not response.text:
                raise ValueError(
                    "Gemini returned an empty response."
                )

            analysis = IncidentAnalysisResponse.model_validate_json(
                response.text
            )

        if analysis.incidentID != incident.id:
            analysis = analysis.model_copy(
                update={"incidentID": incident.id}
            )

        logger.info(
            "Analysis completed for incident %s with confidence %s",
            incident.id,
            analysis.confidence,
        )

        return analysis

    except RuntimeError as error:
        logger.exception(
            "Backend configuration error for incident %s",
            incident.id,
        )

        raise HTTPException(
            status_code=500,
            detail=str(error),
        ) from error

    except Exception as error:
        logger.exception(
            "Gemini analysis failed for incident %s",
            incident.id,
        )

        raise HTTPException(
            status_code=500,
            detail=(
                "Gemini incident analysis failed: "
                f"{type(error).__name__}: {str(error)}"
            ),
        ) from error


# MARK: - Postmortem Models

class PostmortemAnalysisInput(BaseModel):
    rootCause: str
    confidence: int
    explanation: str


class RemediationResultInput(BaseModel):
    action: str
    recoveryTimeSeconds: int
    affectedCustomers: int


class PostmortemRequest(BaseModel):
    incident: IncidentRequest
    analysis: PostmortemAnalysisInput
    result: RemediationResultInput


class PreventionActionResponse(BaseModel):
    title: str
    description: str
    priority: str


class IncidentPostmortemResponse(BaseModel):
    id: str
    incidentID: str
    generatedAt: str
    summary: str
    rootCause: str
    resolution: str
    customerImpact: str
    preventionActions: List[PreventionActionResponse]


# MARK: - Postmortem Endpoint

@app.post(
    "/postmortem",
    response_model=IncidentPostmortemResponse,
)
def generate_postmortem(
    request: PostmortemRequest,
) -> IncidentPostmortemResponse:
    incident = request.incident
    analysis = request.analysis
    result = request.result

    prompt = f"""
You are BCE Sentinel AI, an enterprise incident-response system.

Generate a concise enterprise incident postmortem using the supplied
incident, root-cause analysis, and remediation result.

INCIDENT:

{incident.model_dump_json(indent=2)}

ROOT-CAUSE ANALYSIS:

{analysis.model_dump_json(indent=2)}

REMEDIATION RESULT:

{result.model_dump_json(indent=2)}

REQUIREMENTS:

1. Set incidentID to exactly "{incident.id}".
2. Set rootCause to the supplied root cause.
3. Explain the incident in clear enterprise language.
4. Describe the remediation that was executed.
5. Describe customer impact truthfully.
6. Return exactly three prevention actions.
7. Use only high, medium, or low for priority.
8. Do not invent customer impact beyond the supplied result.
9. Do not claim that this action occurred in a real production system.
10. This is a controlled hackfest simulation.
11. Return only data matching the required schema.
"""

    try:
        logger.info(
            "Generating postmortem for incident %s",
            incident.id,
        )

        client = create_genai_client()

        response = client.models.generate_content(
            model=MODEL_NAME,
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0.2,
                response_mime_type="application/json",
                response_schema=IncidentPostmortemResponse,
            ),
        )

        if response.parsed is not None:
            if isinstance(
                response.parsed,
                IncidentPostmortemResponse,
            ):
                postmortem = response.parsed
            else:
                postmortem = IncidentPostmortemResponse.model_validate(
                    response.parsed
                )
        else:
            if not response.text:
                raise ValueError(
                    "Gemini returned an empty postmortem response."
                )

            postmortem = (
                IncidentPostmortemResponse.model_validate_json(
                    response.text
                )
            )

        postmortem = postmortem.model_copy(
            update={
                "id": incident.id + "-postmortem",
                "incidentID": incident.id,
                "generatedAt": datetime.now(
                    timezone.utc
                ).isoformat().replace("+00:00", "Z"),
                "rootCause": analysis.rootCause,
            }
        )

        logger.info(
            "Postmortem generated for incident %s",
            incident.id,
        )

        return postmortem

    except Exception as error:
        logger.exception(
            "Postmortem generation failed for incident %s",
            incident.id,
        )

        raise HTTPException(
            status_code=500,
            detail=(
                "Gemini postmortem generation failed: "
                f"{type(error).__name__}: {str(error)}"
            ),
        ) from error
