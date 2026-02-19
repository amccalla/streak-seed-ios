//
//  ProFeature.swift
//  StreakSeed
//
//  Enum describing Pro-only features for the paywall.
//

import Foundation

enum ProFeature: String, CaseIterable, Identifiable {
    case multiSeed
    case widgets
    case smartNudges
    case streakShield
    case advancedStats
    case themes
    case customEmojis

    var id: String { rawValue }

    var title: String {
        switch self {
        case .multiSeed:     return String(localized: "Multiple Seeds")
        case .widgets:       return String(localized: "Widgets")
        case .smartNudges:   return String(localized: "Smart Nudges")
        case .streakShield:  return String(localized: "Streak Shield")
        case .advancedStats: return String(localized: "Advanced Stats")
        case .themes:        return String(localized: "Themes")
        case .customEmojis:  return String(localized: "Custom Emojis")
        }
    }

    var subtitle: String {
        switch self {
        case .multiSeed:     return String(localized: "Grow up to 5 habits and watch your garden bloom")
        case .widgets:       return String(localized: "Quick check-ins from your Home & Lock Screen")
        case .smartNudges:   return String(localized: "Gentle reminders only when you need them")
        case .streakShield:  return String(localized: "Protect your streak from slip-ups")
        case .advancedStats: return String(localized: "7/30/90-day trends & calendar heatmap")
        case .themes:        return String(localized: "Personalize your seed with color themes")
        case .customEmojis:  return String(localized: "Add your own emoji as habit icons")
        }
    }

    var iconName: String {
        switch self {
        case .multiSeed:     return "leaf.fill"
        case .widgets:       return "rectangle.on.rectangle"
        case .smartNudges:   return "bell.badge"
        case .streakShield:  return "shield.checkered"
        case .advancedStats: return "chart.bar"
        case .themes:        return "paintpalette"
        case .customEmojis:  return "face.smiling"
        }
    }
}
