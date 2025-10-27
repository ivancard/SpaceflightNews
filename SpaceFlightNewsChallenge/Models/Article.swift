//
//  Article.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 25/10/2025.
//

import Foundation

struct Article: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let url: String
    let imageUrl: String
    let newsSite: String
    let summary: String
    let publishedAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, url
        case imageUrl = "image_url"
        case newsSite = "news_site"
        case summary
        case publishedAt = "published_at"
        case updatedAt = "updated_at"
    }
}
