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
final class AppCoordinator: ObservableObject, Coordinator, SearchViewDelegate {
    typealias R = AppRoute

    let router = Router<AppRoute>()
    private let dependencies: AppDependencies
    private var cancellables = Set<AnyCancellable>()
    private lazy var homeViewModel: HomeViewModel = {
        HomeViewModel(
            repository: dependencies.articlesRepository,
            openArticle: { [weak self] article in
                print("[AppCoordinator] openArticle ->", article.id)
                self?.router.push(.articleDetail(article: article))
            },
            openSearch: { [weak self] in
                self?.navigateToSearch()
            }
        )
    }()

    init(dependencies: AppDependencies = .shared) {
        self.dependencies = dependencies
        router.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func start() -> AnyView {
        let navigation = NavigationStack(path: Binding(
            get: { self.router.path },
            set: { self.router.path = $0 }
        )) {
            build(.home)
                .navigationDestination(for: AppRoute.self) { route in
                    self.build(route)
                }
        }
        .animation(nil, value: router.path)

        return AnyView(
            ZStack {
                navigation
                overlayLayer
            }
        )
    }

    @ViewBuilder
    private func build(_ route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView(viewModel: homeViewModel)

        case .articleDetail(let article):
            ArticleDetailView(article: article)
        case .searcher:
            EmptyView()
        }
    }

    func searchView(_ viewModel: SearchViewModel, didSubmit query: String) {
        withAnimation(.easeInOut(duration: 0.25)) {
            router.dismissOverlay()
        }
        homeViewModel.applySearch(query: query)
    }

    func searchViewDidRequestClose(_ viewModel: SearchViewModel) {
        withAnimation(.easeInOut(duration: 0.25)) {
            router.dismissOverlay()
        }
    }

    private func navigateToSearch() {
        withAnimation(.easeInOut(duration: 0.25)) {
            router.presentOverlay(.searcher)
        }
    }

    @ViewBuilder
    private var overlayLayer: some View {
        if let route = router.overlayRoute {
            overlay(for: route)
        }
    }

    @ViewBuilder
    private func overlay(for route: AppRoute) -> some View {
        switch route {
        case .searcher:
            SearchView(
                viewModel: SearchViewModel(
                    delegate: self,
                    initialQuery: homeViewModel.searchText
                )
            )
            .ignoresSafeArea()
            .transition(.opacity)
            .zIndex(1)
        default:
            EmptyView()
        }
    }
}
