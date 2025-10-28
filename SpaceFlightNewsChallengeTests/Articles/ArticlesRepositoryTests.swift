//
//  ArticlesRepositoryTests.swift
//  SpaceFlightNewsChallengeTests
//
//  Created by Ivan Cardenas on 26/10/2025.
//

@testable import SpaceFlightNewsChallenge
import XCTest

class ArticlesRepositoryTests: XCTestCase {
    var repository: ArticlesRepository!
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        repository = ArticlesRepository(apiClient: mockAPIClient)
    }
    
    func testFetchArticlesSuccess() async throws {
        mockAPIClient.mockData = TestDataLoader.data(forResource: "articles-respone")
        
        let response = try await repository.fetchArticles(search: nil, limit: 10)
        
        XCTAssertEqual(response.count, 30027)
        XCTAssertEqual(response.results.count, 10)
        XCTAssertEqual(response.results.first?.id, 33645)
        XCTAssertEqual(mockAPIClient.requestedEndpoints.count, 1)
    }
}
