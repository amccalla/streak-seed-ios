//
//  StreakSeedHomeWidget.swift
//  StreakSeedWidget
//
//  Home Screen widget — streak count + today status + 7-day dots.
//  Requires Pro subscription.
//

import SwiftUI
import WidgetKit

// MARK: - Timeline Provider

struct HomeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HomeWidgetEntry {
        HomeWidgetEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (HomeWidgetEntry) -> Void) {
        Task { @MainActor in
            let data = WidgetDataProvider.fetchData()
            completion(HomeWidgetEntry(date: Date(), data: data))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HomeWidgetEntry>) -> Void) {
        Task { @MainActor in
            let data = WidgetDataProvider.fetchData()
            let entry = HomeWidgetEntry(date: Date(), data: data)

            // Refresh at midnight so the widget updates for a new day
            let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
            let timeline = Timeline(entries: [entry], policy: .after(midnight))
            completion(timeline)
        }
    }
}

// MARK: - Entry

struct HomeWidgetEntry: TimelineEntry {
    let date: Date
    let data: WidgetHabitData
}

// MARK: - Widget View

struct HomeWidgetEntryView: View {
    var entry: HomeWidgetEntry
    @Environment(\.widgetFamily) var family

    private var theme: SeedTheme { entry.data.theme }

    var body: some View {
        if entry.data.isPro {
            switch family {
            case .systemSmall:
                smallView
            case .systemMedium:
                mediumView
            default:
                smallView
            }
        } else {
            proLockedView
        }
    }

    // MARK: Pro Locked

    private var proLockedView: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(String(localized: "StreakSeed Pro"))
                .font(.caption.weight(.semibold))

            Text(String(localized: "Upgrade to unlock widgets"))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    // MARK: Small

    private var smallView: some View {
        VStack(spacing: 8) {
            HStack {
                Text(entry.data.habitIcon)
                    .font(.title3)
                Spacer()
                if entry.data.todayCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(theme.primaryColor)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.data.currentStreak)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.primaryColor)

                Text(String(localized: "day streak"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 7-day dots
            HStack(spacing: 4) {
                ForEach(Array(entry.data.last7Days.enumerated()), id: \.offset) { _, day in
                    Circle()
                        .fill(day.completed ? theme.primaryColor : Color.secondary.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    // MARK: Medium

    private var mediumView: some View {
        HStack(spacing: 16) {
            // Left: streak info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(entry.data.habitIcon)
                        .font(.title3)
                    Text(entry.data.habitName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text("\(entry.data.currentStreak)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.primaryColor)

                Text(String(localized: "day streak"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Right: 7-day strip vertical
            VStack(spacing: 4) {
                ForEach(Array(entry.data.last7Days.enumerated()), id: \.offset) { _, day in
                    HStack(spacing: 6) {
                        Text(day.date.singleLetterDay)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .frame(width: 12)

                        Circle()
                            .fill(day.completed ? theme.primaryColor : Color.secondary.opacity(0.2))
                            .frame(width: 12, height: 12)
                            .overlay {
                                if day.completed {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 6, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                }
            }

            // Status badge
            VStack {
                Spacer()
                if entry.data.todayCompleted {
                    Label(String(localized: "Done"), systemImage: "checkmark.circle.fill")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(theme.primaryColor)
                } else {
                    Label(String(localized: "Tap"), systemImage: "drop.fill")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(theme.primaryColor)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Widget Configuration

struct StreakSeedHomeWidget: Widget {
    let kind = "StreakSeedHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HomeWidgetProvider()) { entry in
            HomeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("StreakSeed")
        .description("Track your streak and today's status.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
