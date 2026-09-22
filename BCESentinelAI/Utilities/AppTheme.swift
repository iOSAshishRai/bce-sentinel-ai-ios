//
//  AppTheme.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI

enum AppTheme {
    static let background = Color(
        red: 7 / 255,
        green: 11 / 255,
        blue: 24 / 255
    )

    static let cardBackground = Color(
        red: 17 / 255,
        green: 23 / 255,
        blue: 39 / 255
    )

    static let elevatedCard = Color(
        red: 22 / 255,
        green: 29 / 255,
        blue: 50 / 255
    )

    static let purple = Color(
        red: 118 / 255,
        green: 66 / 255,
        blue: 255 / 255
    )

    static let lightPurple = Color(
        red: 172 / 255,
        green: 130 / 255,
        blue: 255 / 255
    )

    static let critical = Color(
        red: 244 / 255,
        green: 63 / 255,
        blue: 94 / 255
    )

    static let warning = Color(
        red: 245 / 255,
        green: 158 / 255,
        blue: 11 / 255
    )

    static let information = purple

    static let healthy = Color(
        red: 34 / 255,
        green: 197 / 255,
        blue: 94 / 255
    )

    static let primaryText = Color.white

    static let secondaryText = Color(
        red: 157 / 255,
        green: 164 / 255,
        blue: 184 / 255
    )

    static let border = Color.white.opacity(0.08)

    // Backward-compatible alias used by card stroke styles in some views.
    static let cardBorder = border

    static let purpleGradient = LinearGradient(
        colors: [purple, Color.indigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
