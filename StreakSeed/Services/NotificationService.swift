//
//  NotificationService.swift
//  StreakSeed
//
//  Schedules and manages daily reminder + nudge notifications.
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("[Notifications] Permission request failed: \(error)")
            return false
        }
    }

    // MARK: - Schedule Daily Reminder

    func scheduleDailyReminder(hour: Int, minute: Int, habitName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Time to water your seed"
        content.body = "Have you \(habitName.lowercased()) today?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: Constants.dailyReminderId,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[Notifications] Failed to schedule daily: \(error)")
            }
        }
    }

    // MARK: - Schedule Nudge

    /// Schedules a "gentle nudge" near the end of the user's time window.
    func scheduleNudge(hour: Int, minute: Int, habitName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Your window is closing"
        content.body = "Still time to \(habitName.lowercased()) — don't break the chain!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: Constants.nudgeReminderId,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[Notifications] Failed to schedule nudge: \(error)")
            }
        }
    }

    // MARK: - Cancel

    /// Cancel the nudge for today (called when the user marks done).
    func cancelNudge() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Constants.nudgeReminderId])
    }

    /// Cancel all StreakSeed notifications.
    func cancelAll() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [
                Constants.dailyReminderId,
                Constants.nudgeReminderId
            ])
    }
}
