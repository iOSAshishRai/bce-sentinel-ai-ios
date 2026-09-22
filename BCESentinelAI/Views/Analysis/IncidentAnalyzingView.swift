//
//  IncidentAnalyzingView.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

struct IncidentAnalyzingView: View {
    let incident: Incident

    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.purple.opacity(0.12))
                    .frame(width: 150, height: 150)
                    .scaleEffect(isPulsing ? 1.15 : 0.9)
                    .opacity(isPulsing ? 0.15 : 0.8)

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
                    .frame(width: 88, height: 88)
                    .shadow(
                        color: AppTheme.purple.opacity(0.5),
                        radius: 24
                    )

                Image(systemName: "sparkles")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 10) {
                Text("Gemini is analyzing")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.primaryText)

                Text(incident.title)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.lightPurple)

                Text(
                    "Correlating alerts, logs, runbooks, and historical incidents."
                )
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            }

            ProgressView()
                .tint(AppTheme.lightPurple)
                .scaleEffect(1.2)

            Spacer()
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
    }
}
