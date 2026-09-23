//
//  IncidentPostmortem.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import Foundation

struct IncidentPostmortem: Identifiable, Codable, Hashable {
    let id: String
    let incidentID: String
    let generatedAt: Date
    let summary: String
    let rootCause: String
    let resolution: String
    let customerImpact: String
    let preventionActions: [PreventionAction]
}

struct PreventionAction: Identifiable, Codable, Hashable {
    let title: String
    let description: String
    let priority: ActionPriority

    var id: String {
        "\(title)-\(priority.rawValue)"
    }
}

enum ActionPriority: String, Codable {
    case high
    case medium
    case low
}
