//
//  IncidentCard.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

struct IncidentCard: View {
    let incident: Incident

    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(incident.severity.color.opacity(0.18))
                    .frame(width: 48, height: 48)

                Image(systemName: incident.severity.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(incident.severity.color)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(incident.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)

                Text(incident.message)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(relativeTime)
                    Text("•")
                    Text(incident.service)
                }
                .font(.caption2)
                .foregroundStyle(AppTheme.secondaryText.opacity(0.8))
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 14) {
                SeverityBadge(severity: incident.severity)

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(incident.severity.color.opacity(0.12), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated

        return formatter.localizedString(
            for: incident.detectedAt,
            relativeTo: Date()
        )
    }
}
