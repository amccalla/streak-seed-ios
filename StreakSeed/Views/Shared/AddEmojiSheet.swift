//
//  AddEmojiSheet.swift
//  StreakSeed
//
//  A small sheet that lets Pro users type or paste an emoji to add
//  to their custom icon collection.
//

import SwiftUI

struct AddEmojiSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var isFocused: Bool

    /// Called with the validated emoji when the user taps "Add".
    var onAdd: (String) -> Void

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValid: Bool {
        CustomEmojiService.isValidEmoji(trimmed)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(String(localized: "Add Emoji"))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text(String(localized: "Type or paste an emoji"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                // Large preview
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.secondarySystemFill))
                        .frame(width: 100, height: 100)

                    if trimmed.isEmpty {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 40))
                            .foregroundStyle(.quaternary)
                    } else {
                        Text(trimmed)
                            .font(.system(size: 56))
                    }
                }

                // Text field — opens emoji keyboard
                TextField(String(localized: "Tap to type emoji"), text: $text)
                    .font(.system(size: 32))
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .frame(maxWidth: 200)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .onChange(of: text) { _, newValue in
                        // Only keep the last character entered (the emoji)
                        if newValue.count > 1 {
                            text = String(newValue.suffix(1))
                        }
                    }

                // Validation hint
                if !trimmed.isEmpty && !isValid {
                    Text(String(localized: "Please enter a single emoji character"))
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                // Add button
                Button {
                    onAdd(trimmed)
                    dismiss()
                } label: {
                    Text(String(localized: "Add"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isValid ? Color.seedGreen : Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusButton, style: .continuous))
                }
                .disabled(!isValid)

                Spacer()
            }
            .padding(Constants.screenPadding)
            .background(Color.surfaceBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
            }
            .onAppear {
                isFocused = true
            }
        }
        .presentationDetents([.medium])
    }
}
