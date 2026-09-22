//
//  RemediationView.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

struct RemediationView: View {
    let incident: Incident
    let analysis: IncidentAnalysis

    @StateObject private var viewModel = RemediationViewModel()

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            switch viewModel.state {
            case .ready:
                confirmationContent

            case .executing:
                executionContent

            case .completed:
                if let result = viewModel.result {
                    RemediationSuccessView(
                        incident: incident,
                        analysis: analysis,
                        result: result
                    )
                }

            case .failed(let message):
                errorContent(message)
            }
        }
        .navigationTitle("Autonomous Recovery")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private var confirmationContent: some View {
        ScrollView {
            VStack(spacing: 22) {
                recoveryIcon

                VStack(spacing: 8) {
                    Text("Ready to Execute")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.primaryText)

                    Text(analysis.recommendedAction.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.lightPurple)
                }

                incidentCard
                actionCard
                executeButton
                safetyMessage
            }
            .padding(18)
        }
        .scrollIndicators(.hidden)
    }

    private var recoveryIcon: some View {
        ZStack {
            Circle()
                .fill(AppTheme.purple.opacity(0.14))
                .frame(width: 112, height: 112)

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
                .frame(width: 76, height: 76)

            Image(systemName: "bolt.shield.fill")
                .font(.system(size: 32))
                .foregroundStyle(.white)
        }
        .padding(.top, 20)
    }

    private var incidentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Target Incident")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.secondaryText)

            HStack(spacing: 12) {
                Image(systemName: incident.severity.iconName)
                    .font(.title3)
                    .foregroundStyle(incident.severity.color)
                    .frame(width: 42, height: 42)
                    .background(incident.severity.color.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text(incident.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText)

                    Text(incident.service)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()
            }
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Remediation Plan")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)

                Spacer()

                Text("LOW RISK")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppTheme.healthy)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(AppTheme.healthy.opacity(0.14))
                    .clipShape(Capsule())
            }

            Text(analysis.recommendedAction.title)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.lightPurple)

            Text(analysis.recommendedAction.description)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)

            Divider()
                .overlay(Color.white.opacity(0.08))

            Label(
                "Estimated recovery: \(analysis.recommendedAction.estimatedRecoveryTime)",
                systemImage: "clock"
            )
            .font(.caption)
            .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.purple.opacity(0.22), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var executeButton: some View {
        Button {
            Task {
                await viewModel.execute(
                    incident: incident,
                    action: analysis.recommendedAction
                )
            }
        } label: {
            Label(
                "Approve and Execute",
                systemImage: "bolt.fill"
            )
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
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
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }

    private var safetyMessage: some View {
        Label(
            "This hackfest MVP executes a controlled simulation.",
            systemImage: "lock.shield.fill"
        )
        .font(.caption)
        .foregroundStyle(AppTheme.secondaryText)
        .multilineTextAlignment(.center)
    }

    private var executionContent: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(
                        Color.white.opacity(0.08),
                        lineWidth: 12
                    )

                Circle()
                    .trim(
                        from: 0,
                        to: viewModel.progress
                    )
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.lightPurple,
                                AppTheme.purple
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .easeInOut(duration: 0.4),
                        value: viewModel.progress
                    )

                Text("\(Int(viewModel.progress * 100))%")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
            }
            .frame(width: 150, height: 150)

            VStack(spacing: 8) {
                Text("Recovery in Progress")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.primaryText)

                Text(analysis.recommendedAction.title)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.lightPurple)
            }

            VStack(spacing: 16) {
                ForEach(
                    Array(viewModel.steps.enumerated()),
                    id: \.offset
                ) { index, step in
                    recoveryStep(
                        title: step,
                        index: index
                    )
                }
            }
            .padding(18)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 18)

            Spacer()
        }
    }

    private func recoveryStep(
        title: String,
        index: Int
    ) -> some View {
        let isComplete = index < viewModel.currentStep
        let isCurrent = index == viewModel.currentStep

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        isComplete
                            ? AppTheme.healthy.opacity(0.16)
                            : Color.white.opacity(0.06)
                    )
                    .frame(width: 30, height: 30)

                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.healthy)
                } else if isCurrent {
                    ProgressView()
                        .tint(AppTheme.lightPurple)
                        .scaleEffect(0.7)
                } else {
                    Circle()
                        .fill(AppTheme.secondaryText)
                        .frame(width: 6, height: 6)
                }
            }

            Text(title)
                .font(.subheadline)
                .foregroundStyle(
                    isComplete
                        ? AppTheme.primaryText
                        : AppTheme.secondaryText
                )

            Spacer()
        }
    }

    private func errorContent(_ message: String) -> some View {
        ContentUnavailableView {
            Label(
                "Remediation Failed",
                systemImage: "exclamationmark.triangle.fill"
            )
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.execute(
                        incident: incident,
                        action: analysis.recommendedAction
                    )
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.purple)
        }
    }
}
