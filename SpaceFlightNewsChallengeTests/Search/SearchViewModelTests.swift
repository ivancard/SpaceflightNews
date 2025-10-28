//
//  SearchViewModelTests.swift
//  SpaceFlightNewsChallengeTests
//
//  Created by Ivan Cardenas on 28/10/2025.
//

@testable import SpaceFlightNewsChallenge
import XCTest

@MainActor
final class SearchViewModelTests: XCTestCase {
    func testSubmitSearchTrimsAndNotifiesDelegate() {
        let delegate = TestSearchViewDelegate()
        let sut = SearchViewModel(delegate: delegate)
        sut.searchText = "   Mars   "

        sut.submitSearch()

        XCTAssertEqual(delegate.submittedQuery, "Mars")
        XCTAssertEqual(sut.searchText, "Mars")
    }

    func testSubmitSearchIgnoresEmptyQuery() {
        let delegate = TestSearchViewDelegate()
        let sut = SearchViewModel(delegate: delegate)
        sut.searchText = "   \n  "

        sut.submitSearch()

        XCTAssertNil(delegate.submittedQuery)
    }

    func testCancelNotifiesDelegate() {
        let delegate = TestSearchViewDelegate()
        let sut = SearchViewModel(delegate: delegate)

        sut.cancel()

        XCTAssertTrue(delegate.didRequestClose)
    }

    func testClearSearchResetsText() {
        let sut = SearchViewModel()
        sut.searchText = "Europa"

        sut.clearSearch()

        XCTAssertEqual(sut.searchText, "")
    }
}

private final class TestSearchViewDelegate: SearchViewDelegate {
    var submittedQuery: String?
    var didRequestClose = false

    func searchView(_ viewModel: SearchViewModel, didSubmit query: String) {
        submittedQuery = query
    }

    func searchViewDidRequestClose(_ viewModel: SearchViewModel) {
        didRequestClose = true
    }
}
