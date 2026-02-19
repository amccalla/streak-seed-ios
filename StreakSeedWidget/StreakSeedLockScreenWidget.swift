//
//  StreakSeedLockScreenWidget.swift
//  StreakSeedWidget
//
//  Lock Screen widget — circular gauge with streak count.
//  Requires Pro subscription.
//

import SwiftUI
import WidgetKit

// MARK: - Timeline Provider

struct LockScreenWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockScreenWidgetEntry {
        LockScreenWidgetEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (LockScreenWidgetEntry) -> Void) {
        Task { @MainActor in
            let data = WidgetDataProvider.fetchData()
            completion(LockScreenWidgetEntry(date: Date(), data: data))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LockScreenWidgetEntry>) -> Void) {
        Task { @MainActor in
            let data = WidgetDataProvider.fetchData()
            let entry = LockScreenWidgetEntry(date: Date(), data: data)

            let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
            let timeline = Timeline(entries: [entry], policy: .after(midnight))
            completion(timeline)
        }
    }
}

// MARK: - Entry

struct LockScreenWidgetEntry: TimelineEntry {
    let date: Date
    let data: WidgetHabitData
}

// MARK: - Widget Views

struct LockScreenWidgetEntryView: View {
    var entry: LockScreenWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.data.isPro {
            switch family {
            case .accessoryCircular:
                circularView
            case .accessoryInline:
                inlineView
            case .accessoryRectangular:
                rectangularView
            default:
                circularView
            }
        } else {
            proLockedAccessoryView
        }
    }

    // MARK: Pro Locked (Accessory)

    private var proLockedAccessoryView: some View {
        Group {
            switch family {
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    Image(systemName: "lock.fill")
                        .font(.title3)
                }
            case .accessoryInline:
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                    Text(String(localized: "Upgrade to Pro"))
                }
            case .accessoryRectangular:
                HStack {
                    Image(systemName: "lock.fill")
                    Text(String(localized: "StreakSeed Pro"))
                        .font(.caption2.weight(.medium))
                }
            default:
                Image(systemName: "lock.fill")
            }
        }
    }

    // MARK: Circular

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()

            // Progress ring — fills based on 7-day completion rate
            let rate = completionRate
            Circle()
                .trim(from: 0, to: rate)
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(3)

            VStack(spacing: 0) {
                Text("\(entry.data.currentStreak)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                if entry.data.todayCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                } else {
                    Text(String(localized: "day"))
                        .font(.system(size: 8))
                }
            }
        }
    }

    // MARK: Inline

    private var inlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: entry.data.todayCompleted ? "checkmark.circle.fill" : "circle")
            Text("\(entry.data.currentStreak) \(String(localized: "day streak"))")
        }
    }

    // MARK: Rectangular

    private var rectangularView: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.data.habitName)
                    .font(.caption2)
                    .lineLimit(1)

                Text("\(entry.data.currentStreak) \(String(localized: "days"))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }

            Spacer()

            // Mini 7-day dots
            HStack(spacing: 2) {
                ForEach(Array(entry.data.last7Days.enumerated()), id: \.offset) { _, day in
                    Circle()
                        .fill(day.completed ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }

    private var completionRate: Double {
        let completed = entry.data.last7Days.filter(\.completed).count
        return Double(completed) / 7.0
    }
}

// MARK: - Widget Configuration

struct StreakSeedLockScreenWidget: Widget {
    let kind = "StreakSeedLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockScreenWidgetProvider()) { entry in
            LockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Streak")
        .description("Your streak at a glance.")
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}
