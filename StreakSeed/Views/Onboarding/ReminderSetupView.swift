//
//  ReminderSetupView.swift
//  StreakSeed
//
//  Step 3: Set reminder time, optional window, and nudge.
//

import SwiftUI

struct ReminderSetupView: View {
    @Bindable var viewModel: OnboardingViewModel
    var onFinish: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    Text(String(localized: "Set your reminder"))
                        .font(.system(size: 28, weight: .bold, design: .rounded))

                    Text(String(localized: "We'll nudge you so you never miss a day."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)

                // Reminder time
                VStack(alignment: .leading, spacing: 8) {
                    Label(String(localized: "Daily reminder"), systemImage: "bell.fill")
                        .font(.subheadline.weight(.medium))

                    DatePicker(
                        String(localized: "Daily reminder"),
                        selection: $viewModel.reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxHeight: 120)
                }
                .cardStyle()

                // Optional time window
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $viewModel.enableWindow) {
                        Label(String(localized: "Time window"), systemImage: "clock")
                            .font(.subheadline.weight(.medium))
                    }
                    .tint(viewModel.selectedTheme.primaryColor)

                    if viewModel.enableWindow {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(String(localized: "From"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                DatePicker(
                                    String(localized: "From"),
                                    selection: $viewModel.windowStart,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                            }

                            Spacer()

                            VStack(alignment: .leading) {
                                Text(String(localized: "To"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                DatePicker(
                                    String(localized: "To"),
                                    selection: $viewModel.windowEnd,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))

                        // Smart nudge toggle
                        Toggle(isOn: $viewModel.enableNudge) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(localized: "Smart nudge"))
                                    .font(.subheadline.weight(.medium))
                                Text(String(localized: "Gentle reminder near end of window if not done"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(viewModel.selectedTheme.primaryColor)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .cardStyle()
                .animation(.easeInOut(duration: 0.25), value: viewModel.enableWindow)

                Spacer(minLength: 24)

                // Finish
                Button(action: onFinish) {
                    Text(String(localized: "Start Growing"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.selectedTheme.primaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusButton, style: .continuous))
                }
                .pressScale()
            }
            .padding(Constants.screenPadding)
        }
    }
}
