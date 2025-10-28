//
//  SearchViewModel.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 28/10/2025.
//

import Foundation
internal import Combine
import os

@MainActor
protocol SearchViewDelegate: AnyObject {
    func searchView(_ viewModel: SearchViewModel, didSubmit query: String)
    func searchViewDidRequestClose(_ viewModel: SearchViewModel)
}

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String

    weak var delegate: SearchViewDelegate?

    init(delegate: SearchViewDelegate? = nil, initialQuery: String = "") {
        self.delegate = delegate
        self.searchText = initialQuery
    }

    func submitSearch() {
        submitSearch(using: searchText)
    }

    func submitSearch(using query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        searchText = trimmedQuery
        delegate?.searchView(self, didSubmit: trimmedQuery)
    }

    func cancel() {
        delegate?.searchViewDidRequestClose(self)
    }

    func clearSearch() {
        searchText = ""
    }
}
