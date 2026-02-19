//
//  View+Extensions.swift
//  StreakSeed
//

import SwiftUI

// MARK: - Press Scale Button Style

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func pressScale() -> some View {
        buttonStyle(PressScaleButtonStyle())
    }
}

// MARK: - Card Style Modifier

struct CardModifier: ViewModifier {
    var padding: CGFloat = Constants.cardPadding

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(.secondarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusCard, style: .continuous))
    }
}

extension View {
    func cardStyle(padding: CGFloat = Constants.cardPadding) -> some View {
        modifier(CardModifier(padding: padding))
    }
}

// MARK: - Haptics

enum HapticStyle {
    case soft, light, medium, heavy

    var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .soft:   return .soft
        case .light:  return .light
        case .medium: return .medium
        case .heavy:  return .heavy
        }
    }
}

extension View {
    func haptic(_ style: HapticStyle = .soft) {
        UIImpactFeedbackGenerator(style: style.feedbackStyle).impactOccurred()
    }
}
