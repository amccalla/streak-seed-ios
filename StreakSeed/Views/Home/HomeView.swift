//
//  HomeView.swift
//  StreakSeed
//
//  The main screen — hero check-in, streak, week strip, calendar.
//  Supports multiple habits with a scrollable seed selector.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @State private var showSettings = false
    @State private var showStats = false
    @State private var showGarden = false
    @State private var showAddHabit = false
    @State private var showPaywall = false
    @State private var showMaxHabitsAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Multi-seed selector (show when > 1 habit)
                    if viewModel.habits.count > 1 {
                        habitSelector

                        // Garden button (multi-seed) — at the top
                        Button {
                            showGarden = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "leaf.fill")
                                    .foregroundStyle(Color.seedGreen)
                                Text(String(localized: "View Garden"))
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .foregroundStyle(.primary)
                            .cardStyle()
                        }
                        .pressScale()
                    }

                    if let habit = viewModel.habit {
                        // Hero check-in
                        HeroCardView(
                            habit: habit,
                            isCompleted: viewModel.todayCompleted,
                            onWater: { viewModel.markDone() },
                            onUndo: { viewModel.showUndoConfirmation = true }
                        )

                        // Streak badge
                        StreakBadgeView(
                            currentStreak: viewModel.currentStreak,
                            bestStreak: viewModel.bestStreak,
                            theme: habit.theme
                        )

                        // 7-day strip
                        WeekStripView(
                            days: viewModel.last7Days,
                            theme: habit.theme
                        )

                        // Calendar
                        CalendarView(
                            monthDate: viewModel.calendarMonth,
                            data: viewModel.calendarData,
                            theme: habit.theme,
                            onPreviousMonth: { viewModel.previousMonth() },
                            onNextMonth: { viewModel.nextMonth() },
                            onToggleDay: { date in viewModel.toggleDay(date) }
                        )

                    }
                }
                .padding(Constants.screenPadding)
            }
            .background(Color.surfaceBackground)
            .navigationTitle(String(localized: "Today"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showStats = true
                    } label: {
                        Image(systemName: "chart.bar")
                            .foregroundStyle(.primary)
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // Add seed button
                    Button {
                        if viewModel.canAddHabit {
                            showAddHabit = true
                        } else if StoreKitService.shared.isPro {
                            showMaxHabitsAlert = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(Color.seedGreen)
                    }

                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    habit: viewModel.habit,
                    habitCount: viewModel.habits.count,
                    onDelete: {
                        if let habit = viewModel.habit {
                            viewModel.deleteHabit(habit)
                        }
                    }
                )
                .onDisappear { viewModel.refresh() }
            }
            .sheet(isPresented: $showStats) {
                StatsView()
            }
            .sheet(isPresented: $showGarden) {
                GardenView(viewModel: viewModel)
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert(
                String(localized: "Garden is Full"),
                isPresented: $showMaxHabitsAlert
            ) {
                Button(String(localized: "OK")) {}
            } message: {
                Text(String(localized: "You can grow up to \(Constants.proMaxHabits) habits. To add a new one, delete a habit in Settings."))
            }
            .confirmationDialog(String(localized: "Undo today's check-in?"), isPresented: $viewModel.showUndoConfirmation) {
                Button(String(localized: "Undo"), role: .destructive) { viewModel.undoToday() }
                Button(String(localized: "Cancel"), role: .cancel) {}
            }
        }
        .onAppear {
            viewModel.configure(with: modelContext)
        }
    }

    // MARK: - Habit Selector

    private var habitSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(viewModel.habits.enumerated()), id: \.element.id) { index, habit in
                    let isSelected = index == viewModel.selectedHabitIndex
                    let today = Date.today
                    let completed = habit.logs.contains { $0.date.isSameDay(as: today) && $0.didComplete }

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectHabit(at: index)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(habit.icon)
                                .font(.system(size: 18))

                            if isSelected {
                                Text(habit.name)
                                    .font(.caption.weight(.medium))
                                    .lineLimit(1)
                            }

                            if completed {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(habit.theme.primaryColor)
                            }
                        }
                        .padding(.horizontal, isSelected ? 14 : 10)
                        .padding(.vertical, 8)
                        .background(
                            isSelected
                                ? habit.theme.secondaryColor
                                : Color(.secondarySystemFill)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected ? habit.theme.primaryColor : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .pressScale()
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Add Habit Sheet

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: HomeViewModel

    @State private var name = ""
    @State private var icon = "🌱"
    @State private var theme: SeedTheme = .sprout
    @State private var showAddEmoji = false
    @State private var customEmojis: [String] = []

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
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(String(localized: "Plant a new seed"))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Text(String(localized: "Add another habit to your garden"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 16)

                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "Habit name"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField(String(localized: "e.g. Meditate 10 min"), text: $name)
                            .padding(14)
                            .background(Color(.secondarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusButton, style: .continuous))
                    }

                    // Icon
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(String(localized: "Choose your seed"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            if StoreKitService.shared.isPro {
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
                            ForEach(allIcons, id: \.self) { ic in
                                Button {
                                    icon = ic
                                } label: {
                                    Text(ic)
                                        .font(.system(size: 28))
                                        .frame(width: 48, height: 48)
                                        .background(
                                            icon == ic ? theme.secondaryColor : Color(.secondarySystemFill)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(icon == ic ? theme.primaryColor : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }

                    // Theme
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "Seed color"))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            ForEach(SeedTheme.allCases) { t in
                                Button {
                                    theme = t
                                } label: {
                                    Circle()
                                        .fill(t.primaryColor)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: theme == t ? 3 : 0)
                                                .padding(theme == t ? -3 : 0)
                                        )
                                        .overlay(
                                            theme == t
                                                ? Image(systemName: "checkmark")
                                                    .font(.caption.bold())
                                                    .foregroundStyle(.white)
                                                : nil
                                        )
                                }
                            }
                        }
                    }

                    // Plant button
                    Button {
                        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        viewModel.addHabit(name: name.trimmingCharacters(in: .whitespacesAndNewlines), icon: icon, theme: theme)
                        dismiss()
                    } label: {
                        Text(String(localized: "Plant Seed"))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color.gray.opacity(0.3)
                                    : theme.primaryColor
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusButton, style: .continuous))
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .pressScale()
                }
                .padding(Constants.screenPadding)
            }
            .background(Color.surfaceBackground)
            .navigationTitle(String(localized: "New Seed"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
            }
            .sheet(isPresented: $showAddEmoji) {
                AddEmojiSheet { emoji in
                    CustomEmojiService.addEmoji(emoji)
                    customEmojis = CustomEmojiService.loadCustomEmojis()
                }
            }
            .onAppear {
                customEmojis = CustomEmojiService.loadCustomEmojis()
            }
        }
    }
}
