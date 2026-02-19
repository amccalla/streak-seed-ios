//
//  SharedModelContainer.swift
//  StreakSeed
//
//  Provides a shared SwiftData ModelContainer accessible by both
//  the main app and the widget extension via an App Group.
//

import Foundation
import SwiftData

enum SharedModelContainer {
    /// Shared container stored in the App Group directory.
    static let container: ModelContainer = {
        let schema = Schema([Habit.self, HabitLog.self])

        let config = ModelConfiguration(
            "StreakSeed",
            schema: schema,
            url: storeURL,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }()

    /// URL inside the App Group container for the shared store.
    private static var storeURL: URL {
        let appGroupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupId)

        // Fall back to default location if App Group isn't configured yet
        let base = appGroupURL ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

        return base.appendingPathComponent("StreakSeed.store")
    }
}
