//
//  ArticleDetailViewTests.swift
//  SpaceFlightNewsChallengeTests
//
//  Created by Ivan Cardenas on 28/10/2025.
//

@testable import SpaceFlightNewsChallenge
import XCTest

@MainActor
final class ArticleDetailViewTests: XCTestCase {
    func testFormattedPublishedDateHandlesStandardISO() {
        let article = Article.mock(publishedAt: "2024-01-01T00:00:00Z")
        let sut = ArticleDetailView(article: article)

        let expectedDate = ArticleDetailView.displayFormatter.string(from: ArticleDetailView.isoFormatter.date(from: article.publishedAt)!)

        XCTAssertEqual(sut.formattedPublishedDate, expectedDate)
    }

    func testFormattedPublishedDateHandlesFractionalSeconds() {
        let publishedAt = "2024-01-01T00:00:00.123Z"
        let article = Article.mock(publishedAt: publishedAt)
        let sut = ArticleDetailView(article: article)

        let expectedDate = ArticleDetailView.displayFormatter.string(from: ArticleDetailView.isoFormatterWithFractional.date(from: publishedAt)!)

        XCTAssertEqual(sut.formattedPublishedDate, expectedDate)
    }

    func testFormattedPublishedDateReturnsEmptyForInvalidString() {
        let article = Article.mock(publishedAt: "invalid-date")
        let sut = ArticleDetailView(article: article)

        XCTAssertEqual(sut.formattedPublishedDate, "")
    }

    func testPrimaryAuthorReturnsEmptyWhenMissing() {
        let article = Article.mock(authors: [])
        let sut = ArticleDetailView(article: article)

        XCTAssertEqual(sut.primaryAuthor, "")
    }
}
