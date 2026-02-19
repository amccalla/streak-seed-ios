//
//  StreakSeedWidgetBundle.swift
//  StreakSeedWidget
//
//  Widget bundle — registers all StreakSeed widgets.
//

import SwiftUI
import WidgetKit

@main
struct StreakSeedWidgetBundle: WidgetBundle {
    var body: some Widget {
        StreakSeedHomeWidget()
        StreakSeedLockScreenWidget()
    }
}
