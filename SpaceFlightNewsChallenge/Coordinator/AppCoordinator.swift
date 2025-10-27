//
//  AppCoordinator.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 27/10/2025.
//

import Foundation
import SwiftUI
internal import Combine

protocol Coordinator: AnyObject {
    associatedtype R: Hashable
    func start() -> AnyView
}

@MainActor
final class AppCoordinator: ObservableObject, Coordinator {
    typealias R = AppRoute

    let router = Router<AppRoute>()
    private let dependencies: AppDependencies
    private var cancellables = Set<AnyCancellable>()

    init(dependencies: AppDependencies = .shared) {
        self.dependencies = dependencies
        router.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func start() -> AnyView {
        AnyView(
            NavigationStack(path: Binding(
                get: { self.router.path },
                set: { self.router.path = $0 }
            )) {
                build(.home)
                    .navigationDestination(for: AppRoute.self) { route in
                        self.build(route)
                    }
            }
        )
    }

    @ViewBuilder
    private func build(_ route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView(
                viewModel: HomeViewModel(
                    repository: dependencies.articlesRepository,
                    openArticle: { [weak self] article in
                        print("[AppCoordinator] openArticle ->", article.id)
                        self?.router.push(.articleDetail(article: article))
                    }
                )
            )

        case .articleDetail(let article):
            ArticleDetailView(article: article)
        }
    }
}
