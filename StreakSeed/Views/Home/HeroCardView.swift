//
//  HeroCardView.swift
//  StreakSeed
//
//  Big "Water today's seed" / "Watered" check-in button.
//

import SwiftUI

struct HeroCardView: View {
    let habit: Habit
    let isCompleted: Bool
    var onWater: () -> Void
    var onUndo: () -> Void

    @State private var showSprout = false

    var body: some View {
        VStack(spacing: 16) {
            // Icon
            Text(habit.icon)
                .font(.system(size: 48))
                .scaleEffect(showSprout ? 1.2 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: showSprout)

            // Habit name
            Text(habit.name)
                .font(.headline)
                .foregroundStyle(.secondary)

            // Status
            Text(isCompleted ? String(localized: "Watered today") : String(localized: "Not watered yet"))
                .font(.caption)
                .foregroundStyle(isCompleted ? habit.theme.primaryColor : .secondary)

            // Action button
            Button {
                if isCompleted {
                    onUndo()
                } else {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    showSprout = true
                    onWater()
                    // Reset sprout animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showSprout = false
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                    } else {
                        Image(systemName: "drop.fill")
                    }
                    Text(isCompleted ? String(localized: "Watered") : String(localized: "Water today's seed"))
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    isCompleted
                        ? habit.theme.primaryColor.opacity(0.6)
                        : habit.theme.primaryColor
                )
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusHero, style: .continuous))
            }
            .pressScale()

            if !isCompleted {
                Text(String(localized: "Takes 5 seconds"))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .cardStyle(padding: 24)
    }
}
