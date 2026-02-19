//
//  StreakSeedApp.swift
//  StreakSeed
//
//  App entry point — sets up SwiftData ModelContainer.
//

import SwiftUI
import SwiftData

@main
struct StreakSeedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(SharedModelContainer.container)
    }
}
