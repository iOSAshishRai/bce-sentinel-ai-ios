//
//  IncidentAnalysis.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import Foundation

struct IncidentAnalysis: Codable, Hashable {
    let incidentID: String
    let rootCause: String
    let confidence: Int
    let explanation: String
    let evidence: [AnalysisEvidence]
    let similarIncidents: [SimilarIncident]
    let recommendedAction: RemediationAction
}

struct AnalysisEvidence: Identifiable, Codable, Hashable {
    let title: String
    let detail: String

    var id: String {
        "\(title)-\(detail)"
    }
}

struct SimilarIncident: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let matchPercentage: Int
    let resolution: String
}

struct RemediationAction: Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let riskLevel: RemediationRisk
    let estimatedRecoveryTime: String
}

enum RemediationRisk: String, Codable {
    case low
    case medium
    case high
}
