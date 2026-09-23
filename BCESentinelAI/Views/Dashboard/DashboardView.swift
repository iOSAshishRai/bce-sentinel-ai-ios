//
//  DashboardView.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        header
                        greetingSection
                        metricGrid
                        incidentSection
                        SystemHealthCard(healthPercentage: 98.7)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    viewModel.loadIncidents()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                if viewModel.incidents.isEmpty {
                    viewModel.loadIncidents()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
    
        HStack(spacing: 12) {
            Button {
                // Menu action will be added later.
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 11))
            }

            HStack(spacing: 5) {
                Text("BCE")
                    .foregroundStyle(AppTheme.primaryText)

                Text("Sentinel AI")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                AppTheme.lightPurple,
                                AppTheme.purple
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .font(.system(size: 21, weight: .bold))

            Spacer()

            Button {
                // Notification action will be added later.
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(width: 38, height: 38)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 11))

                    Circle()
                        .fill(AppTheme.critical)
                        .frame(width: 8, height: 8)
                        .overlay {
                            Circle()
                                .stroke(AppTheme.background, lineWidth: 2)
                        }
                }
            }
        }
        .padding(.top, 12)
    }

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Good evening, Ops Team 👋")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.primaryText)

            Text("Here’s what’s happening in your environment.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private var metricGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            MetricCard(
                value: "\(viewModel.incidents.count)",
                title: "Active Incidents",
                tint: AppTheme.critical,
                icon: "exclamationmark.triangle.fill"
            )

            MetricCard(
                value: "285",
                title: "Services Monitored",
                tint: AppTheme.lightPurple,
                icon: "server.rack"
            )

            MetricCard(
                value: "47",
                title: "Auto-Healed Today",
                tint: AppTheme.warning,
                icon: "wand.and.stars"
            )

            MetricCard(
                value: "98.7%",
                title: "System Health",
                tint: AppTheme.healthy,
                icon: "heart.fill"
            )
        }
    }

    private var incidentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Active Incidents")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)

                Spacer()

                Button("View All") {
                    // Full incident list will be added later.
                }
                .font(.caption.bold())
                .foregroundStyle(AppTheme.lightPurple)
            }

            if viewModel.isLoading {
                ProgressView()
                    .tint(AppTheme.purple)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(viewModel.incidents) { incident in
                    NavigationLink {
                        IncidentAnalysisView(incident: incident)
                    } label: {
                        IncidentCard(incident: incident)
                    }
                    .buttonStyle(.plain)
                }
            }
            }
        }
    }
#Preview {
    DashboardView()
}
