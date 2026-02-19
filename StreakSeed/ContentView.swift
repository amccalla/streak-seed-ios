//
//  ContentView.swift
//  StreakSeed
//
//  Root view — routes between onboarding and main home screen.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(Constants.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            HomeView()
        } else {
            OnboardingFlowView {
                withAnimation {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}
