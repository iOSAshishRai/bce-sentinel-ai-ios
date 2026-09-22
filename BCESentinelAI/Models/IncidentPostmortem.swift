//
//  IncidentPostmortem.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import Foundation

struct IncidentPostmortem: Identifiable, Codable, Hashable {
    let id: UUID
    let incidentID: String
    let generatedAt: Date
    let summary: String
    let rootCause: String
    let resolution: String
    let customerImpact: String
    let preventionActions: [PreventionAction]

    init(
        id: UUID = UUID(),
        incidentID: String,
        generatedAt: Date = Date(),
        summary: String,
        rootCause: String,
        resolution: String,
        customerImpact: String,
        preventionActions: [PreventionAction]
    ) {
        self.id = id
        self.incidentID = incidentID
        self.generatedAt = generatedAt
        self.summary = summary
        self.rootCause = rootCause
        self.resolution = resolution
        self.customerImpact = customerImpact
        self.preventionActions = preventionActions
    }
}

struct PreventionAction: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let priority: ActionPriority

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        priority: ActionPriority
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
    }
}

enum ActionPriority: String, Codable {
    case high
    case medium
    case low
}
