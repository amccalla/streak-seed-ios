//
//  WelcomeView.swift
//  StreakSeed
//
//  "Grow one habit at a time" — first onboarding screen.
//

import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void

    @State private var showContent = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Hero icon
            Text("🌱")
                .font(.system(size: 80))
                .scaleEffect(showContent ? 1.0 : 0.5)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showContent)

            VStack(spacing: 12) {
                Text("StreakSeed")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text(String(localized: "Grow one habit at a time."))
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

            Spacer()

            VStack(spacing: 16) {
                Text(String(localized: "No lists. No clutter.\nJust daily momentum."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button(action: onContinue) {
                    Text(String(localized: "Get Started"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.seedGreen)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusButton, style: .continuous))
                }
                .pressScale()
            }
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
        }
        .padding(Constants.screenPadding)
        .onAppear { showContent = true }
    }
}
