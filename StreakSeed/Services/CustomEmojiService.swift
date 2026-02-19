//
//  CustomEmojiService.swift
//  StreakSeed
//
//  Manages user-added custom emoji for habit icons. Pro-only feature.
//

import Foundation

struct CustomEmojiService {
    private static let defaults = UserDefaults.standard

    /// Loads saved custom emojis from UserDefaults.
    static func loadCustomEmojis() -> [String] {
        defaults.stringArray(forKey: Constants.customEmojisKey) ?? []
    }

    /// Adds a single emoji if it passes validation and the limit is not reached.
    @discardableResult
    static func addEmoji(_ emoji: String) -> Bool {
        guard isValidEmoji(emoji) else { return false }

        var current = loadCustomEmojis()
        guard current.count < Constants.maxCustomEmojis else { return false }
        guard !current.contains(emoji) else { return false }

        current.append(emoji)
        defaults.set(current, forKey: Constants.customEmojisKey)
        return true
    }

    /// Removes a single emoji from the saved list.
    static func removeEmoji(_ emoji: String) {
        var current = loadCustomEmojis()
        current.removeAll { $0 == emoji }
        defaults.set(current, forKey: Constants.customEmojisKey)
    }

    // MARK: - Validation

    /// Returns `true` when the string is exactly one visible emoji character.
    /// Handles multi-codepoint emoji (ZWJ sequences, skin tones, flags, etc.).
    static func isValidEmoji(_ string: String) -> Bool {
        // Must be exactly one grapheme cluster (one visible character)
        guard string.count == 1 else { return false }
        // Must not be a plain ASCII character (letters, digits, punctuation)
        guard string.unicodeScalars.count > 1
            || string.unicodeScalars.first.map({ $0.properties.isEmoji && ($0.properties.isEmojiPresentation || $0.value > 0x238C) }) == true
        else { return false }
        return true
    }
}
