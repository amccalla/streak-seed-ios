//
//  GardenView.swift
//  StreakSeed
//
//  Multi-habit garden view with plant growth visualization
//  and consistency chart across all seeds.
//

import SwiftUI

struct GardenView: View {
    var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: StatPeriod = .week

    enum StatPeriod: String, CaseIterable {
        case week, month, quarter

        var label: String {
            switch self {
            case .week: return String(localized: "7 days")
            case .month: return String(localized: "30 days")
            case .quarter: return String(localized: "90 days")
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Plant growth garden
                    gardenSection

                    // Period picker
                    Picker(String(localized: "Period"), selection: $selectedPeriod) {
                        ForEach(StatPeriod.allCases, id: \.self) { period in
                            Text(period.label).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Consistency chart
                    consistencyChart

                    // Today's status
                    todayStatusSection
                }
                .padding(Constants.screenPadding)
            }
            .background(Color.surfaceBackground)
            .navigationTitle(String(localized: "Garden"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
        }
    }

    // MARK: - Plant Growth Garden

    private var gardenSection: some View {
        VStack(spacing: 12) {
            Text(String(localized: "Your Garden"))
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .bottom, spacing: 0) {
                ForEach(viewModel.habits, id: \.id) { habit in
                    let rate = StreakService.completionRate(from: habit.logs, days: 30)
                    let streak = StreakService.currentStreak(from: habit.logs)

                    VStack(spacing: 6) {
                        // Plant visualization
                        PlantView(
                            completionRate: rate,
                            streak: streak,
                            theme: habit.theme,
                            icon: habit.icon
                        )

                        Text(habit.name)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
        }
        .cardStyle()
    }

    // MARK: - Consistency Chart

    private var consistencyChart: some View {
        let days: Int = {
            switch selectedPeriod {
            case .week: return 7
            case .month: return 30
            case .quarter: return 90
            }
        }()

        let data = viewModel.allHabitsCompletionData(days: days)

        return VStack(alignment: .leading, spacing: 14) {
            Text(String(localized: "Consistency"))
                .font(.subheadline.weight(.semibold))

            ForEach(data, id: \.habit.id) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(item.habit.icon)
                            .font(.system(size: 16))
                        Text(item.habit.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Text("\(Int(item.rate * 100))%")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(item.habit.theme.primaryColor)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.1))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(item.habit.theme.primaryColor)
                                .frame(width: geo.size.width * item.rate, height: 8)
                                .animation(.easeOut(duration: 0.6), value: item.rate)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Today's Status

    private var todayStatusSection: some View {
        let statuses = viewModel.allHabitsTodayStatus()
        let completedCount = statuses.filter(\.completed).count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "Today"))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(completedCount)/\(statuses.count) \(String(localized: "done"))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(statuses, id: \.habit.id) { item in
                HStack(spacing: 10) {
                    Text(item.habit.icon)
                        .font(.system(size: 18))

                    Text(item.habit.name)
                        .font(.subheadline)
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(item.completed ? item.habit.theme.primaryColor : Color(.tertiaryLabel))
                        .font(.title3)
                }
                .padding(.vertical, 2)
            }
        }
        .cardStyle()
    }
}

// MARK: - Plant Growth Visualization

struct PlantView: View {
    let completionRate: Double
    let streak: Int
    let theme: SeedTheme
    let icon: String

    /// Growth stage: 0 = seed, 1 = sprout, 2 = small plant, 3 = medium, 4 = blooming
    private var growthStage: Int {
        if streak == 0 { return 0 }
        if streak < 3 { return 1 }
        if streak < 7 { return 2 }
        if streak < 14 { return 3 }
        return 4
    }

    /// How many leaf pairs to show (0–3), based on streak strength
    private var leafPairCount: Int {
        if streak < 3 { return 0 }
        if streak < 7 { return 1 }
        if streak < 14 { return 2 }
        return 3
    }

    /// Total stem height — extends fully from icon to ground
    private var stemHeight: CGFloat {
        switch growthStage {
        case 0: return 0
        case 1: return 18
        case 2: return 34
        case 3: return 52
        default: return 66
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Ground / soil at the bottom
            groundView

            // Stem + icon stacked above the ground
            if growthStage >= 1 {
                VStack(spacing: 0) {
                    // Icon at top
                    Text(icon)
                        .font(.system(size: iconSize))

                    // Stem with leaves overlaid
                    stemWithLeaves
                }
                .offset(y: -4) // sit just above ground center
            }
        }
        .frame(height: 120, alignment: .bottom)
    }

    private var iconSize: CGFloat {
        switch growthStage {
        case 1: return 16
        case 2: return 18
        case 3: return 24
        default: return 30
        }
    }

    // MARK: - Stem with leaves

    private var stemWithLeaves: some View {
        ZStack {
            // Continuous stem bar from icon to ground
            RoundedRectangle(cornerRadius: 1.5)
                .fill(theme.primaryColor.opacity(0.55))
                .frame(width: 3, height: stemHeight)

            // Overlay leaf pairs at evenly-spaced positions
            if leafPairCount > 0 {
                leafOverlay
            }
        }
        .frame(height: stemHeight)
    }

    private var leafOverlay: some View {
        // Distribute leaves evenly along the stem
        // Position 0.0 = top of stem, 1.0 = bottom
        GeometryReader { geo in
            let h = geo.size.height
            ForEach(0..<leafPairCount, id: \.self) { i in
                let fraction = leafPosition(index: i)
                let y = h * fraction
                let leafSize = leafSizeForIndex(i)
                leafPair(size: leafSize)
                    .position(x: geo.size.width / 2, y: y)
            }
        }
        .frame(width: 60, height: stemHeight)
    }

    /// Vertical position (fraction 0–1) for each leaf pair
    private func leafPosition(index: Int) -> CGFloat {
        switch leafPairCount {
        case 1: return 0.5
        case 2: return index == 0 ? 0.33 : 0.7
        case 3: return index == 0 ? 0.2 : index == 1 ? 0.5 : 0.78
        default: return 0.5
        }
    }

    /// Leaf size grows slightly toward the bottom (older leaves are bigger)
    private func leafSizeForIndex(_ index: Int) -> CGSize {
        let base: CGFloat = growthStage >= 4 ? 14 : 11
        let scale: CGFloat = 1.0 + CGFloat(index) * 0.15
        return CGSize(width: base * scale, height: (base * 0.55) * scale)
    }

    private func leafPair(size: CGSize) -> some View {
        HStack(spacing: 2) {
            // Left leaf
            Ellipse()
                .fill(theme.primaryColor.opacity(0.45))
                .frame(width: size.width, height: size.height)
                .rotationEffect(.degrees(-35))
                .offset(x: -3)

            // Right leaf
            Ellipse()
                .fill(theme.primaryColor.opacity(0.45))
                .frame(width: size.width, height: size.height)
                .rotationEffect(.degrees(35))
                .offset(x: 3)
        }
    }

    // MARK: - Ground

    private var groundView: some View {
        ZStack {
            // Soil
            Ellipse()
                .fill(Color(hex: "8D6E63").opacity(0.3))
                .frame(width: 36, height: 10)

            // Seed (only at stage 0)
            if growthStage == 0 {
                Circle()
                    .fill(theme.primaryColor.opacity(0.4))
                    .frame(width: 12, height: 12)
                    .offset(y: -6)
            }
        }
    }
}
