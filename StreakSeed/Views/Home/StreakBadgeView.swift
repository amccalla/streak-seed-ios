//
//  StreakBadgeView.swift
//  StreakSeed
//
//  Displays current streak (large) and best streak (small).
//

import SwiftUI

struct StreakBadgeView: View {
    let currentStreak: Int
    let bestStreak: Int
    let theme: SeedTheme

    var body: some View {
        HStack(spacing: 24) {
            // Current streak
            VStack(spacing: 4) {
                Text("\(currentStreak)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.primaryColor)
                    .contentTransition(.numericText(value: Double(currentStreak)))
                    .animation(.spring(response: 0.35), value: currentStreak)

                Text(String(localized: "Current streak"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Divider
            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 1, height: 40)

            // Best streak
            VStack(spacing: 4) {
                Text("\(bestStreak)")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(String(localized: "Best streak"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}
