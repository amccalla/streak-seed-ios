//
//  HabitLog.swift
//  StreakSeed
//
//  SwiftData model for a single day's check-in record.
//

import Foundation
import SwiftData

@Model
final class HabitLog {
    var id: UUID
    /// Normalized to local start-of-day.
    var date: Date
    /// When the user marked it complete (nil if not yet done).
    var completedAt: Date?
    var didComplete: Bool

    var habit: Habit?

    init(date: Date, didComplete: Bool = false, completedAt: Date? = nil) {
        self.id = UUID()
        self.date = date.startOfDay
        self.didComplete = didComplete
        self.completedAt = completedAt
    }
}
