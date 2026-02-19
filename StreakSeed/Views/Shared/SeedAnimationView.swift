//
//  SeedAnimationView.swift
//  StreakSeed
//
//  Subtle sprout/growth micro-animation for the check-in moment.
//

import SwiftUI

struct SeedAnimationView: View {
    @State private var isGrowing = false

    let color: Color

    var body: some View {
        ZStack {
            // Expanding ring
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 2)
                .scaleEffect(isGrowing ? 2.0 : 1.0)
                .opacity(isGrowing ? 0 : 0.5)

            // Sparkle dots
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(color.opacity(0.6))
                    .frame(width: 4, height: 4)
                    .offset(y: isGrowing ? -30 : 0)
                    .rotationEffect(.degrees(Double(index) * 60))
                    .opacity(isGrowing ? 0 : 1)
            }
        }
        .frame(width: 60, height: 60)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isGrowing = true
            }
        }
    }
}
