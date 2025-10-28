//
//  HomeViewTests.swift
//  SpaceFlightNewsChallengeTests
//
//  Created by Ivan Cardenas on 28/10/2025.
//

@testable import SpaceFlightNewsChallenge
import SwiftUI
import XCTest

@MainActor
final class HomeViewTests: XCTestCase {
    func testTrimmedSearchQueryRemovesWhitespace() {
        let repository = MockArticlesRepository()
        let viewModel = HomeViewModel(repository: repository)
        viewModel.searchText = "   Jupiter  "

        let sut = HomeView(viewModel: viewModel)

        XCTAssertEqual(sut.trimmedSearchQuery, "Jupiter")
    }

    func testInitKeepsInjectedViewModelInstance() {
        let repository = MockArticlesRepository()
        let customViewModel = HomeViewModel(repository: repository)

        let sut = HomeView(viewModel: customViewModel)
        let mirror = Mirror(reflecting: sut)
        let stateObject = mirror.children.first { $0.label == "_viewModel" }?.value as? StateObject<HomeViewModel>

        XCTAssertNotNil(stateObject)
        XCTAssertTrue(stateObject?.wrappedValue === customViewModel)
    }
}
