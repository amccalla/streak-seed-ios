//
//  HomeViewModel.swift
//  StreakSeed
//
//  Drives the Today / Home screen — supports multiple habits.
//

import Foundation
import SwiftData
import Observation

@Observable
final class HomeViewModel {
    var habits: [Habit] = []
    var habit: Habit?  // Currently selected / primary habit
    var todayCompleted: Bool = false
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var last7Days: [(date: Date, completed: Bool)] = []
    var calendarMonth: Date = Date.today
    var calendarData: [(date: Date, completed: Bool)] = []
    var showUndoConfirmation: Bool = false
    var selectedHabitIndex: Int = 0

    /// Animated streak counter target.
    var animatedStreak: Int = 0

    private var modelContext: ModelContext?

    var maxHabits: Int {
        StoreKitService.shared.isPro ? Constants.proMaxHabits : Constants.freeMaxHabits
    }

    var canAddHabit: Bool {
        habits.count < maxHabits
    }

    func configure(with context: ModelContext) {
        self.modelContext = context
        loadHabits()
        refresh()
    }

    // MARK: - Load

    private func loadHabits() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
        habits = (try? context.fetch(descriptor)) ?? []
        if selectedHabitIndex >= habits.count {
            selectedHabitIndex = 0
        }
        habit = habits.isEmpty ? nil : habits[selectedHabitIndex]
    }

    func selectHabit(at index: Int) {
        guard index < habits.count else { return }
        selectedHabitIndex = index
        habit = habits[index]
        refresh()
    }

    func refresh() {
        loadHabits()
        guard let habit else { return }
        let logs = habit.logs

        todayCompleted = logs.contains { $0.date.isSameDay(as: Date.today) && $0.didComplete }
        currentStreak = StreakService.currentStreak(from: logs)
        bestStreak = StreakService.bestStreak(from: logs)
        last7Days = StreakService.last7Days(from: logs)
        calendarData = StreakService.monthData(from: logs, for: calendarMonth)
    }

    // MARK: - Actions

    func markDone() {
        guard let habit, let context = modelContext else { return }

        let today = Date.today

        if let existingLog = habit.logs.first(where: { $0.date.isSameDay(as: today) }) {
            existingLog.didComplete = true
            existingLog.completedAt = Date()
        } else {
            let log = HabitLog(date: today, didComplete: true, completedAt: Date())
            log.habit = habit
            context.insert(log)
        }

        try? context.save()
        NotificationService.shared.cancelNudge()
        refresh()
    }

    func undoToday() {
        guard let habit, let context = modelContext else { return }

        if let todayLog = habit.logs.first(where: { $0.date.isSameDay(as: Date.today) }) {
            todayLog.didComplete = false
            todayLog.completedAt = nil
            try? context.save()
        }

        refresh()
    }

    func toggleDay(_ date: Date) {
        guard let habit, let context = modelContext else { return }

        if let existingLog = habit.logs.first(where: { $0.date.isSameDay(as: date) }) {
            existingLog.didComplete.toggle()
            existingLog.completedAt = existingLog.didComplete ? Date() : nil
        } else {
            let log = HabitLog(date: date, didComplete: true, completedAt: Date())
            log.habit = habit
            context.insert(log)
        }

        try? context.save()
        refresh()
    }

    // MARK: - Add Habit

    func addHabit(name: String, icon: String, theme: SeedTheme) {
        guard let context = modelContext else { return }
        let habit = Habit(name: name, icon: icon, colorTheme: theme)
        context.insert(habit)
        try? context.save()
        loadHabits()
        selectHabit(at: habits.count - 1)
    }

    func deleteHabit(_ habit: Habit) {
        guard let context = modelContext else { return }
        context.delete(habit)
        try? context.save()
        loadHabits()
        if selectedHabitIndex >= habits.count {
            selectedHabitIndex = max(0, habits.count - 1)
        }
        self.habit = habits.isEmpty ? nil : habits[selectedHabitIndex]
        refresh()
    }

    // MARK: - Calendar Navigation

    func previousMonth() {
        calendarMonth = calendarMonth.addingMonths(-1)
        refresh()
    }

    func nextMonth() {
        calendarMonth = calendarMonth.addingMonths(1)
        refresh()
    }

    // MARK: - Multi-Habit Data (for Garden view)

    func allHabitsCompletionData(days: Int) -> [(habit: Habit, rate: Double)] {
        habits.map { h in
            let rate = StreakService.completionRate(from: h.logs, days: days)
            return (habit: h, rate: rate)
        }
    }

    func allHabitsTodayStatus() -> [(habit: Habit, completed: Bool)] {
        let today = Date.today
        return habits.map { h in
            let completed = h.logs.contains { $0.date.isSameDay(as: today) && $0.didComplete }
            return (habit: h, completed: completed)
        }
    }
}
