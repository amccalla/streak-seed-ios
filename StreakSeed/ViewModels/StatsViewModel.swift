//
//  StatsViewModel.swift
//  StreakSeed
//
//  Computes completion rates, trends, and advanced stats.
//

import Foundation
import SwiftData
import Observation

@Observable
final class StatsViewModel {
    var completionRate7: Double = 0
    var completionRate30: Double = 0
    var completionRate90: Double = 0
    var weeklyTrend: Int = 0
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var totalCompleted: Int = 0
    var totalDays: Int = 0

    private var modelContext: ModelContext?

    func configure(with context: ModelContext) {
        self.modelContext = context
        refresh()
    }

    func refresh() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
        guard let habit = try? context.fetch(descriptor).first else { return }

        let logs = habit.logs

        completionRate7 = StreakService.completionRate(from: logs, days: 7)
        completionRate30 = StreakService.completionRate(from: logs, days: 30)
        completionRate90 = StreakService.completionRate(from: logs, days: 90)
        weeklyTrend = StreakService.weeklyTrend(from: logs)
        currentStreak = StreakService.currentStreak(from: logs)
        bestStreak = StreakService.bestStreak(from: logs)
        totalCompleted = logs.filter(\.didComplete).count

        let daysSinceCreation = Date.today.daysSince(habit.createdAt.startOfDay) + 1
        totalDays = max(1, daysSinceCreation)
    }

    var trendText: String {
        if weeklyTrend > 0 {
            return String(localized: "You're up +\(weeklyTrend) day\(weeklyTrend == 1 ? "" : "s") vs last week")
        } else if weeklyTrend < 0 {
            return String(localized: "Down \(weeklyTrend) day\(weeklyTrend == -1 ? "" : "s") vs last week")
        } else {
            return String(localized: "Same as last week — keep it up!")
        }
    }
}
