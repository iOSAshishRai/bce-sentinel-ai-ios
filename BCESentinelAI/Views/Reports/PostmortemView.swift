//
//  PostmortemView.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI
import Combine

struct PostmortemView: View {
    let incident: Incident
    let analysis: IncidentAnalysis
    let result: RemediationResult

    @StateObject private var viewModel = PostmortemViewModel()

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            switch viewModel.state {
            case .idle, .generating:
                generatingContent

            case .loaded:
                if let postmortem = viewModel.postmortem {
                    postmortemContent(postmortem)
                }

            case .failed(let message):
                errorContent(message)
            }
        }
        .navigationTitle("AI Postmortem")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
        .task {
            if viewModel.state == .idle {
                await generatePostmortem()
            }
        }
    }

    private var generatingContent: some View {
        VStack(spacing: 26) {
            ZStack {
                Circle()
                    .fill(AppTheme.purple.opacity(0.14))
                    .frame(width: 130, height: 130)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.lightPurple,
                                AppTheme.purple
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 82, height: 82)

                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 9) {
                Text("Generating Postmortem")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.primaryText)

                Text("Gemini is documenting the incident, resolution, impact, and prevention actions.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            ProgressView()
                .tint(AppTheme.lightPurple)
                .scaleEffect(1.2)
        }
    }

    private func postmortemContent(
        _ postmortem: IncidentPostmortem
    ) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                reportHeader(postmortem)

                reportSection(
                    title: "Incident Summary",
                    icon: "doc.text.fill",
                    content: postmortem.summary,
                    color: AppTheme.information
                )

                reportSection(
                    title: "Root Cause",
                    icon: "exclamationmark.magnifyingglass",
                    content: postmortem.rootCause,
                    color: AppTheme.critical
                )

                reportSection(
                    title: "Resolution",
                    icon: "bolt.shield.fill",
                    content: postmortem.resolution,
                    color: AppTheme.lightPurple
                )

                reportSection(
                    title: "Customer Impact",
                    icon: "person.2.fill",
                    content: postmortem.customerImpact,
                    color: AppTheme.healthy
                )

                preventionSection(postmortem.preventionActions)

                knowledgeCaptureCard
            }
            .padding(18)
            .padding(.bottom, 25)
        }
        .scrollIndicators(.hidden)
    }

    private func reportHeader(
        _ postmortem: IncidentPostmortem
    ) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.healthy.opacity(0.14))
                    .frame(width: 74, height: 74)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(AppTheme.healthy)
            }

            VStack(spacing: 5) {
                Text("Postmortem Generated")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.primaryText)

                Text(postmortem.incidentID)
                    .font(.caption.monospaced())
                    .foregroundStyle(AppTheme.lightPurple)

                Text(
                    postmortem.generatedAt,
                    format: .dateTime
                        .day()
                        .month()
                        .year()
                        .hour()
                        .minute()
                )
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.healthy.opacity(0.12),
                    AppTheme.cardBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func reportSection(
        title: String,
        icon: String,
        content: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(color)

            Text(content)
                .font(.subheadline)
                .foregroundStyle(AppTheme.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.18), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func preventionSection(
        _ actions: [PreventionAction]
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(
                "Prevention Actions",
                systemImage: "shield.checkered"
            )
            .font(.headline)
            .foregroundStyle(AppTheme.warning)

            ForEach(actions) { action in
                preventionRow(action)

                if action.id != actions.last?.id {
                    Divider()
                        .overlay(Color.white.opacity(0.07))
                }
            }
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    AppTheme.warning.opacity(0.18),
                    lineWidth: 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func preventionRow(
        _ action: PreventionAction
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(priorityColor(action.priority))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(action.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.primaryText)

                    Spacer()

                    Text(action.priority.rawValue.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(priorityColor(action.priority))
                }

                Text(action.description)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var knowledgeCaptureCard: some View {
        HStack(spacing: 13) {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundStyle(AppTheme.lightPurple)

            VStack(alignment: .leading, spacing: 4) {
                Text("Knowledge Captured")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)

                Text(
                    "This resolution is now available for future incident analysis."
                )
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.healthy)
        }
        .padding(16)
        .background(AppTheme.purple.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func priorityColor(
        _ priority: ActionPriority
    ) -> Color {
        switch priority {
        case .high:
            return AppTheme.critical
        case .medium:
            return AppTheme.warning
        case .low:
            return AppTheme.healthy
        }
    }

    private func errorContent(_ message: String) -> some View {
        ContentUnavailableView {
            Label(
                "Generation Failed",
                systemImage: "exclamationmark.triangle.fill"
            )
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task {
                    await generatePostmortem()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.purple)
        }
    }

    private func generatePostmortem() async {
        await viewModel.generate(
            incident: incident,
            analysis: analysis,
            result: result
        )
    }
}
