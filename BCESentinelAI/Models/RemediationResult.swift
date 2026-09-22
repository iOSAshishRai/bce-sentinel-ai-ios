//
//  RemediationResult.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import Foundation

struct RemediationResult: Codable, Hashable {
    let incidentID: String
    let action: String
    let recoveryTimeSeconds: Int
    let affectedCustomers: Int
    let completedAt: Date
}
