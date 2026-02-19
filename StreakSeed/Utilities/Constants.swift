//
//  Constants.swift
//  StreakSeed
//

import Foundation

enum Constants {
    // MARK: - StoreKit Product IDs
    static let proAnnualProductId = "com.streakseed.pro.annual"
    static let proLifetimeProductId = "com.streakseed.pro.lifetime"
    static let proMonthlyProductId = "com.streakseed.pro.monthly"

    static let allProductIds: Set<String> = [
        proAnnualProductId,
        proLifetimeProductId,
        proMonthlyProductId
    ]

    // MARK: - UserDefaults Keys
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let streakShieldUsedDates = "streakShieldUsedDates"
    static let isProKey = "isProUser"
    static let customEmojisKey = "customEmojis"

    // MARK: - Custom Emojis
    static let maxCustomEmojis = 20

    // MARK: - App Group
    static let appGroupId = "group.com.streakseed.shared"

    // MARK: - Notification Identifiers
    static let dailyReminderId = "streakseed.daily.reminder"
    static let nudgeReminderId = "streakseed.nudge.reminder"

    // MARK: - Streak Shield
    static let freeShieldsPerMonth = 0
    static let proShieldsPerMonth = 3

    // MARK: - Multi-Seed
    static let freeMaxHabits = 1
    static let proMaxHabits = 5

    // MARK: - Layout
    static let screenPadding: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let cornerRadiusCard: CGFloat = 16
    static let cornerRadiusButton: CGFloat = 12
    static let cornerRadiusHero: CGFloat = 24
}
