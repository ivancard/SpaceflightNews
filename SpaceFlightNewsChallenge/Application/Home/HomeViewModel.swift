//
//  HomeViewModel.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 25/10/2025.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
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
        
        do {
            let response = try await repository.fetchArticles(
                search: searchText.isEmpty ? nil : searchText,
                limit: 10
            )
            articles = response.results
        } catch {
            errorMessage = error.localizedDescription
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
        searchText = query
        repository.resetPagination()
        isShowingSearchResults = !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        Task {
            await loadArticles()
        }
    }

    func clearSearch() {
        searchTask?.cancel()
        searchText = ""
        isShowingSearchResults = false
        repository.resetPagination()

        Task {
            await loadArticles()
        }
    }
}
