//
//  AppDependencies.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 26/10/2025.
//

import Foundation

class AppDependencies {
    static let shared = AppDependencies()
    
    let apiClient: APIClientProtocol
    let articlesRepository: ArticlesRepositoryProtocol
    
    private init() {
        self.apiClient = APIClient()
        self.articlesRepository = ArticlesRepository(apiClient: apiClient)
    }
}
