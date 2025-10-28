//
//  APIClient.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 25/10/2025.
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

class APIClient: APIClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.asURLRequest()
        
        #if DEBUG
        print("📡 [APIClient] Request: \(request.url?.absoluteString ?? "unknown")")
        #endif
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                #if DEBUG
                print("❌ [APIClient] Invalid response type")
                #endif
                throw APIError.invalidResponse
            }
            
            #if DEBUG
            print("📊 [APIClient] Status Code: \(httpResponse.statusCode)")
            #endif
            
            guard (200...299).contains(httpResponse.statusCode) else {
                #if DEBUG
                print("❌ [APIClient] HTTP Error: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
                #endif
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decodedData = try decoder.decode(T.self, from: data)
                
                #if DEBUG
                print("✅ [APIClient] Successfully decoded response")
                #endif
                
                return decodedData
            } catch {
                #if DEBUG
                print("❌ [APIClient] Decoding error: \(error)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
                #endif
                throw APIError.decodingError(error)
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            #if DEBUG
            print("❌ [APIClient] Network error: \(error.localizedDescription)")
            #endif
            throw APIError.networkError(error)
        }
    }
}
