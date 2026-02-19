//
//  SettingsView.swift
//  StreakSeed
//
//  Edit habit, reminders, Pro status, and reset.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SettingsViewModel()
    @State private var showPaywall = false
    @State private var showIconPicker = false
    @State private var showAddEmoji = false
    @State private var newEmojiText = ""
    @State private var customEmojis: [String] = []
    @State private var showDeleteConfirmation = false

    /// The habit to edit — passed from HomeView so we edit the correct one.
    var habit: Habit?
    /// Total number of habits — used to prevent deleting the last one.
    var habitCount: Int = 1
    /// Called when the user confirms deletion of this habit.
    var onDelete: (() -> Void)?

    private let defaultIcons = [
        "🌱", "📖", "💧", "🏋️", "💊",
        "🧘", "✍️", "😴", "🏃", "🎸",
        "🧠", "🥗", "🎯", "🔥", "⭐️",
        "💪", "🚶", "🧹", "🎨", "📝",
        "🍎", "☕️", "🛌", "🚿"
    ]

    private var allIcons: [String] {
        defaultIcons + customEmojis
    }

    var body: some View {
        NavigationStack {
            Form {
                // Habit section
                Section(String(localized: "Your Habit")) {
                    TextField(String(localized: "Habit name"), text: $viewModel.habitName)

                    Button {
                        showIconPicker.toggle()
                    } label: {
                        HStack {
                            Text(String(localized: "Icon"))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(viewModel.selectedIcon)
                                .font(.title2)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    if showIconPicker {
                        if StoreKitService.shared.isPro {
                            HStack {
                                Spacer()
                                Button {
                                    showAddEmoji = true
                                } label: {
                                    Label(String(localized: "Add Emoji"), systemImage: "plus.circle")
                                        .font(.caption)
                                        .foregroundStyle(Color.seedGreen)
                                }
                            }
                        }

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(allIcons, id: \.self) { icon in
                                Text(icon)
                                    .font(.system(size: 28))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        viewModel.selectedIcon == icon
                                            ? viewModel.selectedTheme.secondaryColor
                                            : Color.clear
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(
                                                viewModel.selectedIcon == icon ? viewModel.selectedTheme.primaryColor : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        viewModel.selectedIcon = icon
                                    }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Picker(String(localized: "Theme"), selection: $viewModel.selectedTheme) {
                        ForEach(SeedTheme.allCases) { theme in
                            HStack {
                                Circle()
                                    .fill(theme.primaryColor)
                                    .frame(width: 16, height: 16)
                                Text(theme.displayName)
                            }
                            .tag(theme)
                        }
                    }
                }

                // Reminders section
                Section(String(localized: "Reminders")) {
                    DatePicker(
                        String(localized: "Daily reminder"),
                        selection: $viewModel.reminderTime,
                        displayedComponents: .hourAndMinute
                    )

                    Toggle(String(localized: "Time window"), isOn: $viewModel.enableWindow)
                        .tint(Color.seedGreen)

                    if viewModel.enableWindow {
                        DatePicker(String(localized: "From"), selection: $viewModel.windowStart, displayedComponents: .hourAndMinute)
                        DatePicker(String(localized: "To"), selection: $viewModel.windowEnd, displayedComponents: .hourAndMinute)

                        Toggle(String(localized: "Smart nudge"), isOn: $viewModel.enableNudge)
                            .tint(Color.seedGreen)
                    }
                }

                // Pro section
                Section("StreakSeed Pro") {
                    if StoreKitService.shared.isPro {
                        Label(String(localized: "Pro active"), systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Color.seedGreen)
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            Label(String(localized: "Upgrade to Pro"), systemImage: "star.fill")
                                .foregroundStyle(Color.seedGreen)
                        }
                    }

                    Button(String(localized: "Restore Purchases")) {
                        Task { await StoreKitService.shared.restore() }
                    }
                }

                // Danger zone
                Section {
                    if habitCount > 1 {
                        Button(String(localized: "Delete This Habit"), role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }

                    Button(String(localized: "Reset All Data"), role: .destructive) {
                        viewModel.showResetConfirmation = true
                    }
                }
            }
            .navigationTitle(String(localized: "Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Save")) {
                        viewModel.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .confirmationDialog(
                String(localized: "This will delete your habit and all history. This cannot be undone."),
                isPresented: $viewModel.showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button(String(localized: "Reset Everything"), role: .destructive) {
                    viewModel.resetAllData()
                    dismiss()
                }
                Button(String(localized: "Cancel"), role: .cancel) {}
            }
            .confirmationDialog(
                String(localized: "Delete this habit and all its history? This cannot be undone."),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(String(localized: "Delete Habit"), role: .destructive) {
                    onDelete?()
                    dismiss()
                }
                Button(String(localized: "Cancel"), role: .cancel) {}
            }
            .sheet(isPresented: $showAddEmoji) {
                AddEmojiSheet { emoji in
                    CustomEmojiService.addEmoji(emoji)
                    customEmojis = CustomEmojiService.loadCustomEmojis()
                }
            }
        }
        .onAppear {
            viewModel.configure(with: modelContext, habit: habit)
            customEmojis = CustomEmojiService.loadCustomEmojis()
        }
    }
}
