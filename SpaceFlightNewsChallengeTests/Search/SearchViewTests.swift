//
//  SearchViewTests.swift
//  SpaceFlightNewsChallengeTests
//
//  Created by Ivan Cardenas on 28/10/2025.
//

@testable import SpaceFlightNewsChallenge
import XCTest

@MainActor
final class SearchViewTests: XCTestCase {
    func testTrimmedInputRemovesWhitespace() {
        let viewModel = SearchViewModel()
        viewModel.searchText = "   Europa   "

        let sut = SearchView(viewModel: viewModel)

        XCTAssertEqual(sut.trimmedInput, "Europa")
    }

    func testIsSearchTextEmptyUsesTrimmedInput() {
        let viewModel = SearchViewModel()
        viewModel.searchText = "   "

        let sut = SearchView(viewModel: viewModel)

        XCTAssertTrue(sut.isSearchTextEmpty)
    }
}
