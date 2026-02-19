//
//  Color+Theme.swift
//  StreakSeed
//

import SwiftUI

// MARK: - Seed Themes

enum SeedTheme: String, CaseIterable, Codable, Identifiable {
    case sprout
    case ocean
    case sunset
    case lavender
    case ember
    case earth

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sprout:   return "Sprout"
        case .ocean:    return "Ocean"
        case .sunset:   return "Sunset"
        case .lavender: return "Lavender"
        case .ember:    return "Ember"
        case .earth:    return "Earth"
        }
    }

    var primaryColor: Color {
        switch self {
        case .sprout:   return Color(hex: "4CAF50")
        case .ocean:    return Color(hex: "2196F3")
        case .sunset:   return Color(hex: "FF9800")
        case .lavender: return Color(hex: "9C27B0")
        case .ember:    return Color(hex: "F44336")
        case .earth:    return Color(hex: "795548")
        }
    }

    var secondaryColor: Color {
        primaryColor.opacity(0.15)
    }

    var gradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, primaryColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - App Colors

extension Color {
    /// Primary "Seed Green" accent.
    static let seedGreen = Color(hex: "4CAF50")

    /// Muted secondary text.
    static let secondaryText = Color(.secondaryLabel)

    /// Card background that adapts to light/dark.
    static let cardBackground = Color(.secondarySystemGroupedBackground)

    /// Subtle surface for backgrounds.
    static let surfaceBackground = Color(.systemGroupedBackground)
}

// MARK: - Hex Init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
