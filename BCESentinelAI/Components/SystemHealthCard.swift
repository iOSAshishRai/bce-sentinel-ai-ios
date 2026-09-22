//
//  SystemHealthCard.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

struct SystemHealthCard: View {
    let healthPercentage: Double

    private let chartValues: [CGFloat] = [
        0.42, 0.48, 0.56, 0.62, 0.67,
        0.73, 0.69, 0.76, 0.82, 0.74,
        0.63, 0.58, 0.65, 0.72, 0.79,
        0.75, 0.64, 0.57, 0.61, 0.70,
        0.78, 0.84, 0.76, 0.71
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Health")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText)

                    Text("Last 24 hours")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()

                Text("\(Int(healthPercentage))%")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.healthy)
            }

            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    Path { path in
                        guard chartValues.count > 1 else {
                            return
                        }

                        let width = geometry.size.width
                        let height = geometry.size.height
                        let step = width / CGFloat(chartValues.count - 1)

                        for index in chartValues.indices {
                            let x = CGFloat(index) * step
                            let y = height - chartValues[index] * height

                            if index == chartValues.startIndex {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        AppTheme.purpleGradient,
                        style: StrokeStyle(
                            lineWidth: 2.5,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .shadow(color: AppTheme.purple.opacity(0.6), radius: 6)
                }
            }
            .frame(height: 85)

            HStack {
                Text("00:00")
                Spacer()
                Text("06:00")
                Spacer()
                Text("12:00")
                Spacer()
                Text("18:00")
                Spacer()
                Text("24:00")
            }
            .font(.system(size: 9))
            .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.border, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
