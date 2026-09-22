//
//  SeverityBadge.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

struct SeverityBadge: View {
    let severity: IncidentSeverity

    var body: some View {
        Text(severity.title)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(severity.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(severity.color.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
