//
//  Incident.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//


import SwiftUI
import Foundation

struct Incident: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let service: String
    let severity: IncidentSeverity
    let message: String
    let detectedAt: Date
    let probableRootCause: String?
    let recommendedAction: String?
    let status: IncidentStatus
}

enum IncidentSeverity: String, Codable {
    case critical
    case warning
    case information

    var title: String {
        rawValue.uppercased()
    }

    var color: Color {
        switch self {
        case .critical:
            return AppTheme.critical
        case .warning:
            return AppTheme.warning
        case .information:
            return AppTheme.purple
        }
    }

    var iconName: String {
        switch self {
        case .critical:
            return "waveform.path.ecg"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .information:
            return "info.circle.fill"
        }
    }
}

enum IncidentStatus: String, Codable {
    case active
    case analyzing
    case remediating
    case resolved
}
