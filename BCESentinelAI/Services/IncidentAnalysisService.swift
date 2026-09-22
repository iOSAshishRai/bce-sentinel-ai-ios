//
//  IncidentAnalysisService.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import Foundation

protocol IncidentAnalysisServiceProtocol {
    func analyze(_ incident: Incident) async throws -> IncidentAnalysis
}

final class IncidentAnalysisService: IncidentAnalysisServiceProtocol {

    func analyze(_ incident: Incident) async throws -> IncidentAnalysis {
        try await Task.sleep(for: .seconds(2))

        return IncidentAnalysis(
            incidentID: incident.id,
            rootCause: "Database connection pool exhaustion",
            confidence: 91,
            explanation: """
            The Billing API has exhausted the available database \
            connections. New requests are waiting for connections, \
            causing response times to exceed the configured SLA.
            """,
            evidence: [
                AnalysisEvidence(
                    title: "Database connections reached 100%",
                    detail: "The active connection count reached the configured maximum."
                ),
                AnalysisEvidence(
                    title: "API latency increased after deployment",
                    detail: "Latency increased from 420 ms to more than 5 seconds."
                ),
                AnalysisEvidence(
                    title: "Repeated timeout errors detected",
                    detail: "The logs contain 126 connection timeout errors."
                )
            ],
            similarIncidents: [
                SimilarIncident(
                    id: "INC-1023",
                    title: "Billing database timeout",
                    matchPercentage: 96,
                    resolution: "Restarted the Billing API and reset the connection pool."
                ),
                SimilarIncident(
                    id: "INC-1132",
                    title: "Connection pool saturation",
                    matchPercentage: 92,
                    resolution: "Scaled the service from two to four replicas."
                ),
                SimilarIncident(
                    id: "INC-1441",
                    title: "Slow Billing API response",
                    matchPercentage: 88,
                    resolution: "Increased the database connection pool limit."
                )
            ],
            recommendedAction: RemediationAction(
                id: "restart_billing_service",
                title: "Restart Billing Service",
                description: """
                Perform a controlled restart of the unhealthy Billing \
                API instance and verify service health.
                """,
                riskLevel: .low,
                estimatedRecoveryTime: "15 seconds"
            )
        )
    }
}
