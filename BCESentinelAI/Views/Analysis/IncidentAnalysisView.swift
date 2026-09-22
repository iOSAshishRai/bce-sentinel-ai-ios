//
//  IncidentAnalysisView.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

struct IncidentAnalysisView: View {
    let incident: Incident

    @StateObject private var viewModel = IncidentAnalysisViewModel()

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            switch viewModel.state {
            case .idle, .analyzing:
                IncidentAnalyzingView(incident: incident)

            case .loaded:
                if let analysis = viewModel.analysis {
                    analysisContent(analysis)
                }

            case .failed(let message):
                errorContent(message)
            }
        }
        .navigationTitle("Incident Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
        .task {
            if viewModel.state == .idle {
                await viewModel.analyze(incident)
            }
        }
    }

    private func analysisContent(
        _ analysis: IncidentAnalysis
    ) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                incidentHeader
                rootCauseCard(analysis)
                evidenceCard(analysis.evidence)
                similarIncidentCard(analysis.similarIncidents)
                remediationCard(analysis.recommendedAction)
            }
            .padding(18)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
    }

    private var incidentHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(
                    incident.severity.title,
                    systemImage: incident.severity.iconName
                )
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(incident.severity.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(incident.severity.color.opacity(0.14))
                .clipShape(Capsule())

                Spacer()

                Text(incident.id)
                    .font(.caption.monospaced())
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Text(incident.title)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText)

            Text(incident.message)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)

            HStack(spacing: 8) {
                Label(incident.service, systemImage: "server.rack")

                Circle()
                    .fill(AppTheme.secondaryText)
                    .frame(width: 3, height: 3)

                Text(incident.detectedAt, style: .relative)
            }
            .font(.caption)
            .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    incident.severity.color.opacity(0.22),
                    lineWidth: 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func rootCauseCard(
        _ analysis: IncidentAnalysis
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Gemini Analysis", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(AppTheme.lightPurple)

                Spacer()

                Text("COMPLETED")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppTheme.healthy)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(AppTheme.healthy.opacity(0.13))
                    .clipShape(Capsule())
            }

            HStack(alignment: .center, spacing: 18) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Probable Root Cause")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)

                    Text(analysis.rootCause)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 5)

                ConfidenceRing(
                    percentage: analysis.confidence
                )
            }

            Divider()
                .overlay(Color.white.opacity(0.08))

            Text(analysis.explanation)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.purple.opacity(0.17),
                    AppTheme.cardBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    AppTheme.purple.opacity(0.28),
                    lineWidth: 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func evidenceCard(
        _ evidence: [AnalysisEvidence]
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Supporting Evidence", systemImage: "doc.text.magnifyingglass")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            ForEach(evidence) { item in
                EvidenceRow(evidence: item)

                if item.id != evidence.last?.id {
                    Divider()
                        .overlay(Color.white.opacity(0.06))
                        .padding(.leading, 42)
                }
            }
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.cardBorder, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func similarIncidentCard(
        _ incidents: [SimilarIncident]
    ) -> some View {
        NavigationLink {
            SimilarIncidentsView(incidents: incidents)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.information.opacity(0.15))
                        .frame(width: 46, height: 46)

                    Image(systemName: "books.vertical.fill")
                        .foregroundStyle(AppTheme.information)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Historical Knowledge")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText)

                    Text("\(incidents.count) similar incidents found")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(16)
            .background(AppTheme.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        AppTheme.information.opacity(0.22),
                        lineWidth: 1
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    private func remediationCard(
        _ action: RemediationAction
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(
                    "Recommended Action",
                    systemImage: "bolt.shield.fill"
                )
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

                Spacer()

                Text(action.riskLevel.rawValue.uppercased() + " RISK")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppTheme.healthy)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(AppTheme.healthy.opacity(0.14))
                    .clipShape(Capsule())
            }

            Text(action.title)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.primaryText)

            Text(action.description)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)

            Label(
                "Estimated recovery: \(action.estimatedRecoveryTime)",
                systemImage: "clock"
            )
            .font(.caption)
            .foregroundStyle(AppTheme.secondaryText)

            NavigationLink {
                if let analysis = viewModel.analysis {
                    RemediationView(
                        incident: incident,
                        analysis: analysis
                    )
                }
            } label: {
                Label(
                    "Execute Remediation",
                    systemImage: "bolt.fill"
                )
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [
                            AppTheme.lightPurple,
                            AppTheme.purple
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    AppTheme.purple.opacity(0.24),
                    lineWidth: 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func errorContent(_ message: String) -> some View {
        ContentUnavailableView {
            Label(
                "Analysis Failed",
                systemImage: "exclamationmark.triangle.fill"
            )
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.analyze(incident)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.purple)
        }
        .foregroundStyle(AppTheme.primaryText)
    }
}
