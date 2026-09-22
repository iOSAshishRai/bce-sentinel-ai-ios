//
//  PostmortemService.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import Foundation

protocol PostmortemServiceProtocol {
    func generate(
        incident: Incident,
        analysis: IncidentAnalysis,
        result: RemediationResult
    ) async throws -> IncidentPostmortem
}

final class PostmortemService: PostmortemServiceProtocol {

    func generate(
        incident: Incident,
        analysis: IncidentAnalysis,
        result: RemediationResult
    ) async throws -> IncidentPostmortem {
        // Simulates a Gemini API request.
        try await Task.sleep(for: .seconds(2))

        return IncidentPostmortem(
            incidentID: incident.id,
            summary: """
            The \(incident.service) experienced elevated response times \
            after the available database connections reached maximum capacity. \
            The incident was detected and resolved through an automated \
            remediation workflow.
            """,
            rootCause: analysis.rootCause,
            resolution: """
            BCE Sentinel AI performed a controlled restart of the unhealthy \
            Billing API instance. Service health checks completed successfully, \
            and response times returned to normal.
            """,
            customerImpact: """
            No customers were affected during the controlled recovery. \
            The service recovered in \(result.recoveryTimeSeconds) seconds.
            """,
            preventionActions: [
                PreventionAction(
                    title: "Increase connection pool capacity",
                    description: """
                    Review peak database demand and update the connection \
                    pool limit based on expected traffic.
                    """,
                    priority: .high
                ),
                PreventionAction(
                    title: "Add predictive threshold monitoring",
                    description: """
                    Raise an early warning when connection pool utilization \
                    exceeds 75 percent.
                    """,
                    priority: .high
                ),
                PreventionAction(
                    title: "Enable automated service scaling",
                    description: """
                    Scale Billing API replicas when sustained latency or \
                    connection demand exceeds normal thresholds.
                    """,
                    priority: .medium
                )
            ]
        )
    }
}
