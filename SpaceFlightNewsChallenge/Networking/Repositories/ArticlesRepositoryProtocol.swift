//
//  ArticlesRepositoryProtocol.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 25/10/2025.
//

import Foundation

protocol ArticlesRepositoryProtocol {
    func fetchArticles(search: String?, limit: Int) async throws -> PaginatedResponse<Article>
    func fetchNextPage() async throws -> PaginatedResponse<Article>
    func resetPagination()
}
