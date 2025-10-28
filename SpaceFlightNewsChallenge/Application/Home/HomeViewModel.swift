//
//  HomeViewModel.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 25/10/2025.
//

import Foundation
import SwiftUI
internal import Combine

enum HomeViewError: Equatable {
    case connection
    case generic

    var message: String {
        switch self {
        case .connection:
            return "Error de conexión"
        case .generic:
            return "Hubo un error"
        }
    }

    static func map(from error: Error) -> HomeViewError {
        if let apiError = error as? APIError {
            switch apiError {
            case .networkError(let underlying):
                return mapFromURLError(underlying) ?? .connection
            default:
                return .generic
            }
        }

        if let mapped = mapFromURLError(error) {
            return mapped
        }

        return .generic
    }

    private static func mapFromURLError(_ error: Error) -> HomeViewError? {
        guard let urlError = error as? URLError else { return nil }

        let connectionCodes: Set<URLError.Code> = [
            .notConnectedToInternet,
            .networkConnectionLost,
            .timedOut,
            .cannotFindHost,
            .cannotConnectToHost,
            .dnsLookupFailed
        ]

        if connectionCodes.contains(urlError.code) {
            return .connection
        }

        return .generic
    }
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var listError: HomeViewError?
    @Published var searchText = ""
    @Published var isShowingSearchResults = false
    
    private let repository: ArticlesRepositoryProtocol
    private var searchTask: Task<Void, Never>?
    private let openArticle: (Article) -> Void
    private let openSearch: () -> Void
    
    init(
        repository: ArticlesRepositoryProtocol,
        openArticle: @escaping (Article) -> Void = { _ in },
        openSearch: @escaping () -> Void = {}
    ) {
        self.repository = repository
        self.openArticle = openArticle
        self.openSearch = openSearch
    }
    
    func loadArticles() async {
        isLoading = true
        errorMessage = nil
        listError = nil
        
        do {
            let response = try await repository.fetchArticles(
                search: searchText.isEmpty ? nil : searchText,
                limit: 10
            )
            articles = response.results
        } catch {
            errorMessage = error.localizedDescription
            listError = HomeViewError.map(from: error)
        }
        
        isLoading = false
    }
    
    func loadMoreArticles() async {
        guard !isLoading else { return }
        
        do {
            let response = try await repository.fetchNextPage()
            articles.append(contentsOf: response.results)
        } catch {
            errorMessage = error.localizedDescription
            listError = HomeViewError.map(from: error)
        }
    }
    
    func searchArticles() {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // debounce 0.5s
            
            guard !Task.isCancelled else { return }
            
            repository.resetPagination()
            await loadArticles()
        }
    }
    
    func didSelect(article: Article) {
        print("[HomeViewModel] didSelect article", article.id)
        openArticle(article)
    }

    func openSearchScreen() {
        openSearch()
    }

    func applySearch(query: String) {
        searchTask?.cancel()
        isLoading = true
        articles.removeAll()
        searchText = query
        repository.resetPagination()
        isShowingSearchResults = !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        Task {
            await loadArticles()
        }
    }

    func clearSearch() {
        searchTask?.cancel()
        isLoading = true
        articles.removeAll()
        searchText = ""
        isShowingSearchResults = false
        repository.resetPagination()

        Task {
            await loadArticles()
        }
    }
}
