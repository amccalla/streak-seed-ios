//
//  StreakService.swift
//  StreakSeed
//
//  Pure streak calculation logic. No persistence — operates on arrays of HabitLog.
//

import Foundation

struct StreakService {
    /// Current streak: consecutive completed days going backward from today.
    static func currentStreak(from logs: [HabitLog]) -> Int {
        let cal = Calendar.current
        let today = Date.today
        let completedDates = Set(logs.filter(\.didComplete).map(\.date).map { $0.startOfDay })

        var streak = 0
        var checkDate = today

        while completedDates.contains(checkDate) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        return streak
    }

    /// Best streak ever recorded.
    static func bestStreak(from logs: [HabitLog]) -> Int {
        let cal = Calendar.current
        let completedDates = logs.filter(\.didComplete)
            .map { $0.date.startOfDay }
            .sorted()

        guard !completedDates.isEmpty else { return 0 }

        var best = 1
        var current = 1

        for i in 1..<completedDates.count {
            let prev = completedDates[i - 1]
            let curr = completedDates[i]

            // Skip duplicates
            if cal.isDate(prev, inSameDayAs: curr) { continue }

            let daysBetween = curr.daysSince(prev)
            if daysBetween == 1 {
                current += 1
                best = max(best, current)
            } else {
                current = 1
            }
        }

        return best
    }

    /// Completion rate for the last `days` days (0.0 – 1.0).
    static func completionRate(from logs: [HabitLog], days: Int) -> Double {
        let dates = Date.lastNDays(days)
        guard !dates.isEmpty else { return 0 }

        let completedDates = Set(logs.filter(\.didComplete).map { $0.date.startOfDay })
        let completed = dates.filter { completedDates.contains($0.startOfDay) }.count

        return Double(completed) / Double(dates.count)
    }

    /// Trend: difference in completed days this week vs last week.
    static func weeklyTrend(from logs: [HabitLog]) -> Int {
        let cal = Calendar.current
        let today = Date.today

        let thisWeekDates = (0..<7).compactMap { cal.date(byAdding: .day, value: -$0, to: today) }
        let lastWeekDates = (7..<14).compactMap { cal.date(byAdding: .day, value: -$0, to: today) }

        let completedDates = Set(logs.filter(\.didComplete).map { $0.date.startOfDay })

        let thisWeek = thisWeekDates.filter { completedDates.contains($0.startOfDay) }.count
        let lastWeek = lastWeekDates.filter { completedDates.contains($0.startOfDay) }.count

        return thisWeek - lastWeek
    }

    /// Returns completion status for each of the last 7 days.
    static func last7Days(from logs: [HabitLog]) -> [(date: Date, completed: Bool)] {
        let dates = Date.lastNDays(7)
        let completedDates = Set(logs.filter(\.didComplete).map { $0.date.startOfDay })

        return dates.map { date in
            (date: date, completed: completedDates.contains(date.startOfDay))
        }
    }

    /// Returns completion status for each day in a given month.
    static func monthData(from logs: [HabitLog], for monthDate: Date) -> [(date: Date, completed: Bool)] {
        let dates = monthDate.datesInMonth()
        let completedDates = Set(logs.filter(\.didComplete).map { $0.date.startOfDay })

        return dates.map { date in
            (date: date, completed: completedDates.contains(date.startOfDay))
        }
    }
}
