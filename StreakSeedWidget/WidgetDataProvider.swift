//
//  WidgetDataProvider.swift
//  StreakSeedWidget
//
//  Reads habit data from the shared SwiftData store for widget display.
//

import Foundation
import SwiftData
import WidgetKit

struct WidgetHabitData {
    let habitName: String
    let habitIcon: String
    let colorThemeRaw: String
    let currentStreak: Int
    let bestStreak: Int
    let todayCompleted: Bool
    let last7Days: [(date: Date, completed: Bool)]
    let isPro: Bool

    var theme: SeedTheme {
        SeedTheme(rawValue: colorThemeRaw) ?? .sprout
    }

    static let placeholder = WidgetHabitData(
        habitName: "Your Habit",
        habitIcon: "🌱",
        colorThemeRaw: SeedTheme.sprout.rawValue,
        currentStreak: 0,
        bestStreak: 0,
        todayCompleted: false,
        last7Days: Date.lastNDays(7).map { (date: $0, completed: false) },
        isPro: false
    )
}

struct WidgetDataProvider {
    @MainActor
    static func fetchData() -> WidgetHabitData {
        let container = SharedModelContainer.container
        let context = container.mainContext

        // Check Pro status from App Group UserDefaults, with file-based fallback
        let sharedDefaults = UserDefaults(suiteName: Constants.appGroupId)
        var isPro = sharedDefaults?.bool(forKey: Constants.isProKey) ?? false

        if !isPro, let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.appGroupId
        ) {
            let flagURL = containerURL.appendingPathComponent(".isPro")
            isPro = FileManager.default.fileExists(atPath: flagURL.path)
        }

        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
        guard let habit = try? context.fetch(descriptor).first else {
            return .placeholder
        }

        let logs = habit.logs
        let today = Date.today
        let todayCompleted = logs.contains { $0.date.isSameDay(as: today) && $0.didComplete }
        let currentStreak = StreakService.currentStreak(from: logs)
        let bestStreak = StreakService.bestStreak(from: logs)
        let last7 = StreakService.last7Days(from: logs)

        return WidgetHabitData(
            habitName: habit.name,
            habitIcon: habit.icon,
            colorThemeRaw: habit.colorTheme,
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            todayCompleted: todayCompleted,
            last7Days: last7,
            isPro: isPro
        )
    }
}
