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
    var fetchArticlesResults: [Result<PaginatedResponse<Article>, Error>] = []
    var fetchNextPageResults: [Result<PaginatedResponse<Article>, Error>] = []
    private(set) var fetchArticlesCalls: [(search: String?, limit: Int)] = []
    private(set) var fetchNextPageCallCount = 0
    private(set) var resetPaginationCallCount = 0

    func fetchArticles(search: String?, limit: Int) async throws -> PaginatedResponse<Article> {
        fetchArticlesCalls.append((search, limit))

        if !fetchArticlesResults.isEmpty {
            let result = fetchArticlesResults.removeFirst()
            return try result.get()
        }

        if shouldFail {
            throw APIError.networkError(NSError(domain: "Mock", code: 0))
        }

        return mockArticles ?? PaginatedResponse(count: 0, next: nil, previous: nil, results: [])
    }

    func fetchNextPage() async throws -> PaginatedResponse<Article> {
        fetchNextPageCallCount += 1

        if !fetchNextPageResults.isEmpty {
            let result = fetchNextPageResults.removeFirst()
            return try result.get()
        }

        if shouldFail {
            throw APIError.networkError(NSError(domain: "Mock", code: 0))
        }

        return mockArticles ?? PaginatedResponse(count: 0, next: nil, previous: nil, results: [])
    }

    func resetPagination() {
        resetPaginationCallCount += 1
    }

    func enqueueFetchArticles(_ response: PaginatedResponse<Article>) {
        fetchArticlesResults.append(.success(response))
    }

    func enqueueFetchArticles(error: Error) {
        fetchArticlesResults.append(.failure(error))
    }

    func enqueueNextPage(_ response: PaginatedResponse<Article>) {
        fetchNextPageResults.append(.success(response))
    }

    func enqueueNextPage(error: Error) {
        fetchNextPageResults.append(.failure(error))
    }

    func reset() {
        mockArticles = nil
        shouldFail = false
        fetchArticlesResults.removeAll()
        fetchNextPageResults.removeAll()
        fetchArticlesCalls.removeAll()
        fetchNextPageCallCount = 0
        resetPaginationCallCount = 0
    }
}

// MockData.swift
extension Article {
    static var mock: Article {
        .mock()
    }

    static func mock(
        id: Int = 1,
        title: String = "Test Article",
        url: String = "https://test.com",
        imageUrl: String = "https://test.com/image.jpg",
        newsSite: String = "Test Site",
        summary: String = "Test summary",
        publishedAt: String = "2024-01-01T00:00:00Z",
        updatedAt: String = "2024-01-01T00:00:00Z",
        authors: [ArticleAuthor] = [ArticleAuthor(name: "Jeff Foust")]
    ) -> Article {
        Article(
            id: id,
            title: title,
            url: url,
            imageUrl: imageUrl,
            newsSite: newsSite,
            summary: summary,
            publishedAt: publishedAt,
            updatedAt: updatedAt,
            authors: authors
        )
    }
}
