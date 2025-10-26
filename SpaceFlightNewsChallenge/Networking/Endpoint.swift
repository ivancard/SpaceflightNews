//
//  Endpoint.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 25/10/2025.
//

import Foundation

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]
    
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spaceflightnewsapi.net"
        components.path = path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
}

// MARK: - Factory Methods
extension Endpoint {
    static func articles(limit: Int = 10, offset: Int = 0, search: String? = nil) -> Endpoint {
        var queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        
        if let search = search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        
        return Endpoint(path: "/v4/articles", queryItems: queryItems)
    }
    
    static func articleDetail(id: Int) -> Endpoint {
        return Endpoint(path: "/v4/articles/\(id)", queryItems: [])
    }
}
