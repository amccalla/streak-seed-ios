//
//  StatsView.swift
//  StreakSeed
//
//  Lightweight stats: completion rates, trends, streaks.
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Trend
                    VStack(spacing: 8) {
                        Image(systemName: viewModel.weeklyTrend >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.title2)
                            .foregroundStyle(viewModel.weeklyTrend >= 0 ? Color.seedGreen : Color.orange)

                        Text(viewModel.trendText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .cardStyle(padding: 20)

                    // Streaks
                    HStack(spacing: 12) {
                        statCard(
                            title: String(localized: "Current"),
                            value: "\(viewModel.currentStreak)",
                            subtitle: String(localized: "days"),
                            color: .seedGreen
                        )

                        statCard(
                            title: String(localized: "Best"),
                            value: "\(viewModel.bestStreak)",
                            subtitle: String(localized: "days"),
                            color: .orange
                        )
                    }

                    // Completion rates
                    VStack(alignment: .leading, spacing: 16) {
                        Text(String(localized: "Completion Rate"))
                            .font(.subheadline.weight(.semibold))

                        rateRow(label: String(localized: "Last 7 days"), rate: viewModel.completionRate7)
                        rateRow(label: String(localized: "Last 30 days"), rate: viewModel.completionRate30)

                        if StoreKitService.shared.isPro {
                            rateRow(label: String(localized: "Last 90 days"), rate: viewModel.completionRate90)
                        } else {
                            HStack {
                                Text(String(localized: "Last 90 days"))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Label(String(localized: "Pro"), systemImage: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .cardStyle()

                    // Total
                    HStack {
                        Text(String(localized: "Total completed"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(viewModel.totalCompleted) / \(viewModel.totalDays) \(String(localized: "days"))")
                            .font(.subheadline.weight(.medium))
                    }
                    .cardStyle()
                }
                .padding(Constants.screenPadding)
            }
            .background(Color.surfaceBackground)
            .navigationTitle(String(localized: "Stats"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
        }
        .onAppear {
            viewModel.configure(with: modelContext)
        }
    }

    // MARK: - Components

    private func statCard(title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle(padding: 20)
    }

    private func rateRow(label: String, rate: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(rate * 100))%")
                    .font(.subheadline.weight(.medium))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.seedGreen)
                        .frame(width: geo.size.width * rate, height: 6)
                        .animation(.easeOut(duration: 0.5), value: rate)
                }
            }
            .frame(height: 6)
        }
    }
}
