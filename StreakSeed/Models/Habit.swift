//
//  Habit.swift
//  StreakSeed
//
//  SwiftData model for the user's single habit.
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var icon: String                  // Emoji or SF Symbol name
    var colorTheme: String            // SeedTheme raw value
    var reminderHour: Int
    var reminderMinute: Int
    var windowStartHour: Int?
    var windowStartMinute: Int?
    var windowEndHour: Int?
    var windowEndMinute: Int?
    var nudgeEnabled: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    var logs: [HabitLog]

    init(
        name: String,
        icon: String = "🌱",
        colorTheme: SeedTheme = .sprout,
        reminderHour: Int = 9,
        reminderMinute: Int = 0,
        windowStartHour: Int? = nil,
        windowStartMinute: Int? = nil,
        windowEndHour: Int? = nil,
        windowEndMinute: Int? = nil,
        nudgeEnabled: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorTheme = colorTheme.rawValue
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.windowStartHour = windowStartHour
        self.windowStartMinute = windowStartMinute
        self.windowEndHour = windowEndHour
        self.windowEndMinute = windowEndMinute
        self.nudgeEnabled = nudgeEnabled
        self.createdAt = Date()
        self.logs = []
    }

    /// Resolved theme enum.
    var theme: SeedTheme {
        SeedTheme(rawValue: colorTheme) ?? .sprout
    }
}
