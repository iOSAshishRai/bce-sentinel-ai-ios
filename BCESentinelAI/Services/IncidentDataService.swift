//
//  IncidentDataService.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import Foundation

final class IncidentDataService {
    
    func fetchActiveIncidents() -> [Incident] {
        [
            Incident(
                id: "INC-2026-001",
                title: "Billing Platform Latency",
                service: "Billing API",
                severity: .critical,
                message: "Response time exceeded 5 seconds",
                detectedAt: Date().addingTimeInterval(-120),
                probableRootCause: "Connection pool exhaustion",
                recommendedAction: "Restart billing service",
                status: .active
            ),
            
            Incident(
                id: "INC-2026-002",
                title: "Payment Gateway Down",
                service: "Payment Service",
                severity: .critical,
                message: "Service is returning HTTP 503",
                detectedAt: Date().addingTimeInterval(-420),
                probableRootCause: "Unhealthy service instance",
                recommendedAction: "Restart unhealthy instance",
                status: .active
            ),
            
            Incident(
                id: "INC-2026-003",
                title: "Customer Activation High CPU",
                service: "Activation Service",
                severity: .warning,
                message: "CPU utilization exceeded 85%",
                detectedAt: Date().addingTimeInterval(-900),
                probableRootCause: "Unexpected processing workload",
                recommendedAction: "Scale service replicas",
                status: .active
            )
        ]
    }
}
