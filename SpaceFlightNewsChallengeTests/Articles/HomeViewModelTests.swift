//
//  HomeViewModelTests.swift
//  SpaceFlightNewsChallengeTests
//
//  Created by Ivan Cardenas on 26/10/2025.
//

@testable import SpaceFlightNewsChallenge
import XCTest

@MainActor
final class HomeViewModelTests: XCTestCase {
    private var viewModel: HomeViewModel!
    private var repository: MockArticlesRepository!

    override func setUp() {
        super.setUp()
        repository = MockArticlesRepository()
        viewModel = HomeViewModel(repository: repository)
    }

    override func tearDown() {
        repository = nil
        viewModel = nil
        super.tearDown()
    }

    func testLoadArticlesSuccessSetsArticles() async {
        let articles = [Article.mock(id: 1), Article.mock(id: 2)]
        repository.enqueueFetchArticles(
            PaginatedResponse(count: 2, next: nil, previous: nil, results: articles)
        )

        await viewModel.loadArticles()

        XCTAssertEqual(viewModel.articles, articles)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.listError)
    }

    func testLoadArticlesFailureSetsError() async {
        repository.enqueueFetchArticles(error: APIError.networkError(URLError(.notConnectedToInternet)))

        await viewModel.loadArticles()

        XCTAssertTrue(viewModel.articles.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.listError, .connection)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadMoreArticlesAppendsResults() async {
        let initialArticles = [Article.mock(id: 1), Article.mock(id: 2)]
        let nextArticles = [Article.mock(id: 3)]

        repository.enqueueFetchArticles(
            PaginatedResponse(count: 3, next: "next", previous: nil, results: initialArticles)
        )
        repository.enqueueNextPage(
            PaginatedResponse(count: 3, next: nil, previous: nil, results: nextArticles)
        )

        await viewModel.loadArticles()
        await viewModel.loadMoreArticles()

        XCTAssertEqual(viewModel.articles, initialArticles + nextArticles)
        XCTAssertEqual(repository.fetchNextPageCallCount, 1)
    }

    func testApplySearchResetsPaginationAndLoads() async {
        let searchArticles = [Article.mock(id: 10, title: "Mars Mission")]
        repository.enqueueFetchArticles(
            PaginatedResponse(count: 1, next: nil, previous: nil, results: searchArticles)
        )

        viewModel.applySearch(query: "Mars")

        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(repository.resetPaginationCallCount, 1)
        XCTAssertEqual(repository.fetchArticlesCalls.last?.search, "Mars")
        XCTAssertEqual(viewModel.searchText, "Mars")
        XCTAssertTrue(viewModel.isShowingSearchResults)
        XCTAssertEqual(viewModel.articles, searchArticles)
    }

    func testClearSearchResetsStateAndReloads() async {
        let initialArticles = [Article.mock(id: 1)]
        repository.enqueueFetchArticles(
            PaginatedResponse(count: 1, next: nil, previous: nil, results: initialArticles)
        )

        await viewModel.loadArticles()

        repository.enqueueFetchArticles(
            PaginatedResponse(count: 1, next: nil, previous: nil, results: initialArticles)
        )

        viewModel.applySearch(query: "Mars")
        try? await Task.sleep(nanoseconds: 50_000_000)

        repository.enqueueFetchArticles(
            PaginatedResponse(count: 1, next: nil, previous: nil, results: initialArticles)
        )

        viewModel.clearSearch()
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertFalse(viewModel.isShowingSearchResults)
        XCTAssertEqual(repository.resetPaginationCallCount, 2) // applySearch + clearSearch
        XCTAssertEqual(viewModel.articles, initialArticles)
    }
}
