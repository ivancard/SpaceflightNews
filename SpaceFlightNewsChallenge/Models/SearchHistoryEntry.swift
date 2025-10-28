//
//  SearchHistoryEntry.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 28/10/2025.
//

import Foundation
import SwiftData

@Model
final class SearchHistoryEntry {
    @Attribute(.unique) var normalizedTerm: String
    var term: String
    var createdAt: Date

    init(term: String, createdAt: Date = Date()) {
        let normalized = term.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.term = term
        self.normalizedTerm = normalized
        self.createdAt = createdAt
    }

    func update(with newTerm: String) {
        term = newTerm
        normalizedTerm = newTerm.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        createdAt = Date()
    }
}
