//
//  MockAPIClient.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 26/10/2025.
//

import Foundation

class MockAPIClient: APIClientProtocol {
    var mockData: Data?
    var mockError: Error?
    private(set) var requestedEndpoints: [Endpoint] = []
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        requestedEndpoints.append(endpoint)
        
        if let mockError {
            throw mockError
        }
        
        guard let mockData else {
            throw APIError.networkError(NSError(domain: "MockAPIClient", code: -1))
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: mockData)
    }
    
    func reset() {
        mockData = nil
        mockError = nil
        requestedEndpoints.removeAll()
    }
}

class MockArticlesRepository: ArticlesRepositoryProtocol {
    var mockArticles: PaginatedResponse<Article>?
    var shouldFail = false
    
    func fetchArticles(search: String?, limit: Int) async throws -> PaginatedResponse<Article> {
        if shouldFail {
            throw APIError.networkError(NSError(domain: "Mock", code: 0))
        }
        return mockArticles ?? PaginatedResponse(count: 0, next: nil, previous: nil, results: [])
    }
    
    func fetchNextPage() async throws -> PaginatedResponse<Article> {
        if shouldFail {
            throw APIError.networkError(NSError(domain: "Mock", code: 0))
        }
        return mockArticles ?? PaginatedResponse(count: 0, next: nil, previous: nil, results: [])
    }
    
    func resetPagination() {}
}

// MockData.swift
extension Article {
    static var mock: Article {
        Article(
            id: 1,
            title: "Test Article",
            url: "https://test.com",
            imageUrl: "https://test.com/image.jpg",
            newsSite: "Test Site",
            summary: "Test summary",
            publishedAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-01T00:00:00Z"
        )
    }
}
