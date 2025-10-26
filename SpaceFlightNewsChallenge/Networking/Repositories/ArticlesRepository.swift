//
//  ArticlesRepository.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 25/10/2025.
//

import Foundation

class ArticlesRepository: ArticlesRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private var currentOffset = 0
    private var currentSearch: String?
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchArticles(search: String?, limit: Int = 10) async throws -> PaginatedResponse<Article> {
        currentSearch = search
        currentOffset = 0
        
        let endpoint = Endpoint.articles(limit: limit, offset: currentOffset, search: search)
        let response: PaginatedResponse<Article> = try await apiClient.request(endpoint)
        
        currentOffset += limit
        return response
    }
    
    func fetchNextPage() async throws -> PaginatedResponse<Article> {
        let endpoint = Endpoint.articles(limit: 10, offset: currentOffset, search: currentSearch)
        let response: PaginatedResponse<Article> = try await apiClient.request(endpoint)
        
        currentOffset += 10
        return response
    }
    
    func resetPagination() {
        currentOffset = 0
        currentSearch = nil
    }
}
