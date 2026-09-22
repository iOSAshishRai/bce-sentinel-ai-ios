//
//  SimilarIncidentsView.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

struct SimilarIncidentsView: View {
    let incidents: [SimilarIncident]

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 14) {
                    knowledgeSummary

                    ForEach(incidents) { incident in
                        similarIncidentCard(incident)
                    }
                }
                .padding(18)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Similar Incidents")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var knowledgeSummary: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.purple.opacity(0.16))
                    .frame(width: 50, height: 50)

                Image(systemName: "brain.head.profile")
                    .font(.title3)
                    .foregroundStyle(AppTheme.lightPurple)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Enterprise Incident Memory")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)

                Text(
                    "Gemini found \(incidents.count) relevant historical resolutions."
                )
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func similarIncidentCard(
        _ incident: SimilarIncident
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(incident.id)
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(AppTheme.lightPurple)

                Spacer()

                Text("\(incident.matchPercentage)% MATCH")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(matchColor(incident.matchPercentage))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        matchColor(incident.matchPercentage).opacity(0.14)
                    )
                    .clipShape(Capsule())
            }

            Text(incident.title)
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            VStack(alignment: .leading, spacing: 6) {
                Text("Previous Resolution")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.secondaryText)

                Text(incident.resolution)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.primaryText)
            }

            ProgressView(
                value: Double(incident.matchPercentage),
                total: 100
            )
            .tint(matchColor(incident.matchPercentage))
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    matchColor(incident.matchPercentage).opacity(0.2),
                    lineWidth: 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func matchColor(_ percentage: Int) -> Color {
        percentage >= 90
            ? AppTheme.healthy
            : AppTheme.warning
    }
}
