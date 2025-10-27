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
    
    private let repository: ArticlesRepositoryProtocol
    private var searchTask: Task<Void, Never>?
    private let openArticle: (Article) -> Void
    
    init(
        repository: ArticlesRepositoryProtocol,
        openArticle: @escaping (Article) -> Void = { _ in }
    ) {
        self.repository = repository
        self.openArticle = openArticle
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
}
