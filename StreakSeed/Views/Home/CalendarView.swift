//
//  CalendarView.swift
//  StreakSeed
//
//  Month calendar with tap-to-toggle day status.
//

import SwiftUI

struct CalendarView: View {
    let monthDate: Date
    let data: [(date: Date, completed: Bool)]
    let theme: SeedTheme
    var onPreviousMonth: () -> Void
    var onNextMonth: () -> Void
    var onToggleDay: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 12) {
            // Month header
            HStack {
                Button(action: onPreviousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(monthDate.monthYearString)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Button(action: onNextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day grid
            LazyVGrid(columns: columns, spacing: 8) {
                // Leading empty cells for first week offset
                ForEach(0..<leadingEmptyCells, id: \.self) { _ in
                    Color.clear.frame(height: 32)
                }

                ForEach(data, id: \.date) { day in
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onToggleDay(day.date)
                    } label: {
                        ZStack {
                            if day.completed {
                                Circle()
                                    .fill(theme.primaryColor)
                                    .frame(width: 32, height: 32)
                            }

                            if day.date.isSameDay(as: Date.today) && !day.completed {
                                Circle()
                                    .stroke(theme.primaryColor, lineWidth: 2)
                                    .frame(width: 32, height: 32)
                            }

                            Text("\(day.date.dayNumber)")
                                .font(.caption)
                                .foregroundStyle(
                                    day.completed ? Color.white :
                                    (day.date > Date.today ? Color(.tertiaryLabel) : Color.primary)
                                )
                        }
                        .frame(height: 32)
                    }
                    .disabled(day.date > Date.today)
                }
            }
        }
        .cardStyle()
    }

    /// Number of empty cells before the 1st of the month.
    private var leadingEmptyCells: Int {
        guard let firstDate = data.first?.date else { return 0 }
        return (firstDate.weekday - 1) // Sunday = 1, so Sunday = 0 offset
    }
}
