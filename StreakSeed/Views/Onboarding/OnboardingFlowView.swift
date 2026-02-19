//
//  OnboardingFlowView.swift
//  StreakSeed
//
//  Paging container for the onboarding steps.
//

import SwiftUI
import SwiftData

struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    @State private var showPaywall = false
    var onComplete: () -> Void

    var body: some View {
        TabView(selection: $viewModel.currentStep) {
            WelcomeView {
                withAnimation { viewModel.currentStep = 1 }
            }
            .tag(0)

            HabitSetupView(viewModel: viewModel) {
                withAnimation { viewModel.currentStep = 2 }
            }
            .tag(1)

            ReminderSetupView(viewModel: viewModel) {
                Task {
                    await viewModel.createHabit(context: modelContext)
                    showPaywall = true
                }
            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
        .sheet(isPresented: $showPaywall) {
            PaywallView(onDismiss: onComplete)
        }
    }
}
