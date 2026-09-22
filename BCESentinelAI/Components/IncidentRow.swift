//
//  IncidentRow.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

struct IncidentRow: View {
    let incident: Incident

    var body: some View {
        HStack(spacing: 12) {
            incidentIcon

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top) {
                    Text(incident.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 8)

                    severityBadge
                }

                Text(incident.message)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(incident.detectedAt, style: .relative)

                    Circle()
                        .fill(AppTheme.secondaryText)
                        .frame(width: 3, height: 3)

                    Text(incident.service)
                }
                .font(.caption2)
                .foregroundStyle(AppTheme.secondaryText)
            }

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    incident.severity.color.opacity(0.2),
                    lineWidth: 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var incidentIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(incident.severity.color.opacity(0.18))
                .frame(width: 44, height: 44)

            Image(systemName: incident.severity.iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(incident.severity.color)
        }
    }

    private var severityBadge: some View {
        Text(incident.severity.title)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(incident.severity.color)
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            .background(incident.severity.color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    ZStack {
        AppTheme.background
            .ignoresSafeArea()

        IncidentRow(
            incident: Incident(
                id: "INC-2026-001",
                title: "Billing Platform Latency",
                service: "Billing API",
                severity: .critical,
                message: "Response time exceeded 5 seconds",
                detectedAt: Date().addingTimeInterval(-120),
                probableRootCause: "Connection pool exhaustion",
                recommendedAction: "Restart billing service",
                status: .active
            )
        )
        .padding()
    }
}
