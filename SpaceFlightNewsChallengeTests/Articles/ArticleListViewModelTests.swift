//
//  ArticleListViewModelTests.swift
//  SpaceFlightNewsChallengeTests
//
//  Created by Ivan Cardenas on 26/10/2025.
//

@testable import SpaceFlightNewsChallenge
import XCTest

@MainActor
class ArticleListViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var mockRepository: MockArticlesRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockArticlesRepository()
        viewModel = HomeViewModel(repository: mockRepository)
    }
    
    func testLoadArticlesSuccess() async throws {
        let data = TestDataLoader.data(forResource: "articles-respone")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(PaginatedResponse<Article>.self, from: data)
        mockRepository.mockArticles = response
        
        await viewModel.loadArticles()
        
        XCTAssertEqual(viewModel.articles.count, response.results.count)
        XCTAssertEqual(viewModel.articles.first?.id, response.results.first?.id)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadArticlesFailure() async {
        mockRepository.shouldFail = true
        
        await viewModel.loadArticles()
        
        XCTAssertTrue(viewModel.articles.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}
