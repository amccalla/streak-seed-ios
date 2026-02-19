//
//  HabitSetupView.swift
//  StreakSeed
//
//  Step 2: Name your habit, pick an icon, choose a color theme.
//

import SwiftUI

struct HabitSetupView: View {
    @Bindable var viewModel: OnboardingViewModel
    var onContinue: () -> Void

    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    Text(String(localized: "Plant your seed"))
                        .font(.system(size: 28, weight: .bold, design: .rounded))

                    Text(String(localized: "What one habit do you want to grow?"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)

                // Habit name
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Habit"))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField(String(localized: "e.g. Read 10 pages"), text: $viewModel.habitName)
                        .font(.body)
                        .padding(14)
                        .background(Color(.secondarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusButton, style: .continuous))
                        .focused($nameFieldFocused)
                }

                // Suggestions
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Suggestions"))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(viewModel.suggestedHabits, id: \.self) { habit in
                            Button {
                                viewModel.habitName = habit
                                nameFieldFocused = false
                            } label: {
                                Text(habit)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        viewModel.habitName == habit
                                            ? viewModel.selectedTheme.primaryColor.opacity(0.15)
                                            : Color(.secondarySystemFill)
                                    )
                                    .foregroundStyle(viewModel.habitName == habit ? viewModel.selectedTheme.primaryColor : .primary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(
                                            viewModel.habitName == habit ? viewModel.selectedTheme.primaryColor.opacity(0.5) : Color.clear,
                                            lineWidth: 1
                                        )
                                    )
                            }
                        }
                    }
                }

                // Icon picker
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Choose your seed"))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(viewModel.suggestedIcons, id: \.self) { icon in
                            Button {
                                viewModel.selectedIcon = icon
                            } label: {
                                Text(icon)
                                    .font(.system(size: 28))
                                    .frame(width: 48, height: 48)
                                    .background(
                                        viewModel.selectedIcon == icon
                                            ? viewModel.selectedTheme.secondaryColor
                                            : Color(.secondarySystemFill)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(
                                                viewModel.selectedIcon == icon ? viewModel.selectedTheme.primaryColor : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                    }
                }

                // Color theme
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Seed color"))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        ForEach(SeedTheme.allCases) { theme in
                            Button {
                                viewModel.selectedTheme = theme
                            } label: {
                                Circle()
                                    .fill(theme.primaryColor)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: viewModel.selectedTheme == theme ? 3 : 0)
                                            .padding(viewModel.selectedTheme == theme ? -3 : 0)
                                    )
                                    .overlay(
                                        viewModel.selectedTheme == theme
                                            ? Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                            : nil
                                    )
                            }
                        }
                    }
                }

                Spacer(minLength: 24)

                // Continue
                Button(action: onContinue) {
                    Text(String(localized: "Continue"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.isValid ? viewModel.selectedTheme.primaryColor : Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusButton, style: .continuous))
                }
                .disabled(!viewModel.isValid)
                .pressScale()
            }
            .padding(Constants.screenPadding)
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return (positions, CGSize(width: maxWidth, height: totalHeight))
    }
}
