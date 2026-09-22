//
//  EvidenceRow.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

struct EvidenceRow: View {
    let evidence: AnalysisEvidence

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.healthy.opacity(0.14))
                    .frame(width: 30, height: 30)

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.healthy)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(evidence.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)

                Text(evidence.detail)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
