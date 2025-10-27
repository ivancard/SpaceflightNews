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
    private let dependencies = AppDependencies.shared

    var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: HomeViewModel(
                    repository: dependencies.articlesRepository
                )
            )
            .preferredColorScheme(.light)
        }
    }
}
