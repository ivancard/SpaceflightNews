//
//  SpaceFlightNewsChallengeApp.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 24/10/2025.
//

import SwiftUI
import SwiftData

@main
struct SpaceFlightNewsChallengeApp: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.start()
            .preferredColorScheme(.light)
        }
        .modelContainer(for: SearchHistoryEntry.self)
    }
}
