//
//  RemediationSuccessView.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

struct RemediationSuccessView: View {
    let incident: Incident
    let analysis: IncidentAnalysis
    let result: RemediationResult

    @State private var isVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                successIcon

                VStack(spacing: 8) {
                    Text("Incident Resolved")
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppTheme.primaryText)

                    Text(incident.service)
                        .font(.headline)
                        .foregroundStyle(AppTheme.healthy)

                    Label("Healthy", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.healthy)
                }

                metrics
                summaryCard

                NavigationLink {
                    PostmortemView(
                        incident: incident,
                        analysis: analysis,
                        result: result
                    )
                } label: {
                    Label(
                        "Generate AI Postmortem",
                        systemImage: "doc.text.fill"
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
                .buttonStyle(.plain)
            }
            .padding(18)
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.96)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isVisible = true
            }
        }
        .navigationTitle("Remediation Complete")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var successIcon: some View {
        ZStack {
            Circle()
                .fill(AppTheme.healthy.opacity(0.12))
                .frame(width: 140, height: 140)

            Circle()
                .fill(AppTheme.healthy)
                .frame(width: 88, height: 88)

            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.top, 25)
    }

    private var metrics: some View {
        HStack(spacing: 12) {
            resultMetric(
                value: "\(result.recoveryTimeSeconds)s",
                title: "Recovery Time",
                color: AppTheme.lightPurple
            )

            resultMetric(
                value: "85%",
                title: "MTTR Improvement",
                color: AppTheme.information
            )

            resultMetric(
                value: "\(result.affectedCustomers)",
                title: "Customers Affected",
                color: AppTheme.healthy
            )
        }
    }

    private func resultMetric(
        value: String,
        title: String,
        color: Color
    ) -> some View {
        VStack(spacing: 7) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)

            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 96)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recovery Summary")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            summaryRow(
                title: "Root Cause",
                value: analysis.rootCause
            )

            Divider()
                .overlay(Color.white.opacity(0.08))

            summaryRow(
                title: "Action Executed",
                value: result.action
            )

            Divider()
                .overlay(Color.white.opacity(0.08))

            summaryRow(
                title: "Final Status",
                value: "Service Healthy"
            )
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func summaryRow(
        title: String,
        value: String
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)

            Spacer(minLength: 10)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.primaryText)
                .multilineTextAlignment(.trailing)
        }
    }
}
