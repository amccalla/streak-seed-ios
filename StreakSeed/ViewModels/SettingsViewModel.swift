//
//  SettingsViewModel.swift
//  StreakSeed
//
//  Manages editing the habit, reminders, and app settings.
//

import Foundation
import SwiftData
import Observation

@Observable
final class SettingsViewModel {
    var habit: Habit?
    var habitName: String = ""
    var selectedIcon: String = "🌱"
    var selectedTheme: SeedTheme = .sprout
    var reminderTime: Date = Date()
    var enableWindow: Bool = false
    var windowStart: Date = Date()
    var windowEnd: Date = Date()
    var enableNudge: Bool = false
    var showResetConfirmation = false

    private var modelContext: ModelContext?

    func configure(with context: ModelContext, habit: Habit? = nil) {
        self.modelContext = context
        loadHabit(habit)
    }

    private func loadHabit(_ passedHabit: Habit? = nil) {
        if let passedHabit {
            self.habit = passedHabit
        } else {
            guard let context = modelContext else { return }
            let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
            guard let habit = try? context.fetch(descriptor).first else { return }
            self.habit = habit
        }
        guard let habit else { return }

        habitName = habit.name
        selectedIcon = habit.icon
        selectedTheme = habit.theme
        enableNudge = habit.nudgeEnabled

        let cal = Calendar.current
        var reminderComponents = DateComponents()
        reminderComponents.hour = habit.reminderHour
        reminderComponents.minute = habit.reminderMinute
        reminderTime = cal.date(from: reminderComponents) ?? Date()

        if let startH = habit.windowStartHour, let startM = habit.windowStartMinute,
           let endH = habit.windowEndHour, let endM = habit.windowEndMinute {
            enableWindow = true
            var startComponents = DateComponents()
            startComponents.hour = startH
            startComponents.minute = startM
            windowStart = cal.date(from: startComponents) ?? Date()

            var endComponents = DateComponents()
            endComponents.hour = endH
            endComponents.minute = endM
            windowEnd = cal.date(from: endComponents) ?? Date()
        }
    }

    func save() {
        guard let habit, let context = modelContext else { return }
        let cal = Calendar.current

        habit.name = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        habit.icon = selectedIcon
        habit.colorTheme = selectedTheme.rawValue
        habit.nudgeEnabled = enableNudge

        let reminderComponents = cal.dateComponents([.hour, .minute], from: reminderTime)
        habit.reminderHour = reminderComponents.hour ?? 9
        habit.reminderMinute = reminderComponents.minute ?? 0

        if enableWindow {
            let startComponents = cal.dateComponents([.hour, .minute], from: windowStart)
            let endComponents = cal.dateComponents([.hour, .minute], from: windowEnd)
            habit.windowStartHour = startComponents.hour
            habit.windowStartMinute = startComponents.minute
            habit.windowEndHour = endComponents.hour
            habit.windowEndMinute = endComponents.minute
        } else {
            habit.windowStartHour = nil
            habit.windowStartMinute = nil
            habit.windowEndHour = nil
            habit.windowEndMinute = nil
        }

        try? context.save()

        // Reschedule notifications
        NotificationService.shared.cancelAll()
        NotificationService.shared.scheduleDailyReminder(
            hour: habit.reminderHour,
            minute: habit.reminderMinute,
            habitName: habit.name
        )

        if enableNudge, let endH = habit.windowEndHour, let endM = habit.windowEndMinute {
            NotificationService.shared.scheduleNudge(hour: endH, minute: endM, habitName: habit.name)
        }
    }

    func resetAllData() {
        guard let context = modelContext else { return }

        // Delete all habits and logs
        try? context.delete(model: HabitLog.self)
        try? context.delete(model: Habit.self)
        try? context.save()

        NotificationService.shared.cancelAll()
        UserDefaults.standard.set(false, forKey: Constants.hasCompletedOnboarding)
    }
}
