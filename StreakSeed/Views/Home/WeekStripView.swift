//
//  WeekStripView.swift
//  StreakSeed
//
//  7-day circle strip showing recent momentum.
//

import SwiftUI

struct WeekStripView: View {
    let days: [(date: Date, completed: Bool)]
    let theme: SeedTheme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                VStack(spacing: 6) {
                    Text(day.date.singleLetterDay)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    ZStack {
                        Circle()
                            .fill(day.completed ? theme.primaryColor : Color.clear)
                            .frame(width: 32, height: 32)

                        Circle()
                            .stroke(
                                day.date.isSameDay(as: Date.today)
                                    ? theme.primaryColor
                                    : (day.completed ? Color.clear : Color.secondary.opacity(0.3)),
                                lineWidth: day.date.isSameDay(as: Date.today) ? 2.5 : 1
                            )
                            .frame(width: 32, height: 32)

                        if day.completed {
                            Image(systemName: "checkmark")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .cardStyle()
    }
}
