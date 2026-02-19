//
//  OnboardingViewModel.swift
//  StreakSeed
//
//  Manages the multi-step onboarding flow state and habit creation.
//

import Foundation
import SwiftData
import Observation

@Observable
final class OnboardingViewModel {
    // Step 1: Habit setup
    var habitName: String = ""
    var selectedIcon: String = "🌱"
    var selectedTheme: SeedTheme = .sprout

    // Step 2: Reminders
    var reminderTime: Date = {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    var enableWindow: Bool = false
    var windowStart: Date = {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    var windowEnd: Date = {
        var components = DateComponents()
        components.hour = 21
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    var enableNudge: Bool = false

    // Flow
    var currentStep: Int = 0

    // Suggested habit icons
    let suggestedIcons = [
        "🌱", "📖", "💧", "🏋️", "💊",
        "🧘", "✍️", "😴", "🏃", "🎸",
        "🧠", "🥗"
    ]

    // Suggested habit names (localized)
    var suggestedHabits: [String] {
        [
            String(localized: "Read 10 pages"),
            String(localized: "Drink 8 glasses of water"),
            String(localized: "Go to the gym"),
            String(localized: "Take my meds"),
            String(localized: "Meditate 10 min"),
            String(localized: "Journal for 5 min"),
            String(localized: "Stretch for 10 min"),
            String(localized: "Sleep by 11pm"),
            String(localized: "Walk 10,000 steps"),
            String(localized: "Practice guitar")
        ]
    }

    var isValid: Bool {
        !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Create Habit

    func createHabit(context: ModelContext) async {
        let cal = Calendar.current
        let reminderComponents = cal.dateComponents([.hour, .minute], from: reminderTime)

        var windowStartHour: Int?
        var windowStartMinute: Int?
        var windowEndHour: Int?
        var windowEndMinute: Int?

        if enableWindow {
            let startComponents = cal.dateComponents([.hour, .minute], from: windowStart)
            let endComponents = cal.dateComponents([.hour, .minute], from: windowEnd)
            windowStartHour = startComponents.hour
            windowStartMinute = startComponents.minute
            windowEndHour = endComponents.hour
            windowEndMinute = endComponents.minute
        }

        let habit = Habit(
            name: habitName.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: selectedIcon,
            colorTheme: selectedTheme,
            reminderHour: reminderComponents.hour ?? 9,
            reminderMinute: reminderComponents.minute ?? 0,
            windowStartHour: windowStartHour,
            windowStartMinute: windowStartMinute,
            windowEndHour: windowEndHour,
            windowEndMinute: windowEndMinute,
            nudgeEnabled: enableNudge
        )

        context.insert(habit)
        try? context.save()

        // Request notification permission and schedule
        let granted = await NotificationService.shared.requestPermission()
        if granted {
            NotificationService.shared.scheduleDailyReminder(
                hour: reminderComponents.hour ?? 9,
                minute: reminderComponents.minute ?? 0,
                habitName: habit.name
            )

            if enableNudge, let endHour = windowEndHour, let endMinute = windowEndMinute {
                NotificationService.shared.scheduleNudge(
                    hour: endHour,
                    minute: endMinute,
                    habitName: habit.name
                )
            }
        }

        UserDefaults.standard.set(true, forKey: Constants.hasCompletedOnboarding)
    }
}
