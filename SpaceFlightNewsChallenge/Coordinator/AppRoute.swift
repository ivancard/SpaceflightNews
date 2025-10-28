//
//  AppRoute.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 27/10/2025.
//

import Foundation

enum AppRoute: Hashable {
    case home
    case articleDetail(article: Article)
    case searcher
}
