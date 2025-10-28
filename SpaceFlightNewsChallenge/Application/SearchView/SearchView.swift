//
//  SearchView.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 27/10/2025.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @FocusState private var isSearchFieldFocused: Bool
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\SearchHistoryEntry.createdAt, order: .reverse)], animation: .default)
    private var historyEntries: [SearchHistoryEntry]

    @MainActor
    init(viewModel: SearchViewModel? = nil) {
        if let viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(wrappedValue: SearchViewModel())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            historyContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            isSearchFieldFocused = true
        }
        .navigationBarBackButtonHidden()
    }
}

private extension SearchView {
    var header: some View {
        HStack(alignment: .center, spacing: 16) {
            searchBar
            cancelButton
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .padding(.top, 60)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorsHelper.mainLight)
        .ignoresSafeArea(edges: .top)
    }

    var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.gray.opacity(0.7))

            searchTextField

            if !isSearchTextEmpty {
                clearButton
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }

    var searchTextField: some View {
        TextField(
            "Buscar en Space Flight News",
            text: $viewModel.searchText
        )
        .textInputAutocapitalization(.none)
        .disableAutocorrection(true)
        .submitLabel(.search)
        .focused($isSearchFieldFocused)
        .onSubmit {
            performSearch(with: viewModel.searchText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(isSearchTextEmpty ? Color.gray.opacity(0.7) : Color.primary)
        .opacity(isSearchTextEmpty ? 0.9 : 1)
    }

    var clearButton: some View {
        Button {
            viewModel.clearSearch()
            isSearchFieldFocused = true
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(Color.gray.opacity(0.6))
                .imageScale(.medium)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Limpiar búsqueda")
    }

    var cancelButton: some View {
        Button {
            viewModel.cancel()
        } label: {
            Text("Cancelar")
                .bold()
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    var historyContent: some View {
        if historyEntries.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "clock")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(Color.gray.opacity(0.3))
                Text("Sin búsquedas recientes")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 48)
        } else {
            List {
                Section("Historial de búsquedas") {
                    ForEach(historyEntries) { entry in
                        Button {
                            performSearch(with: entry.term)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "clock")
                                    .foregroundStyle(ColorsHelper.grayLight)
                                Text(entry.term)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteHistoryEntry(entry)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private extension SearchView {
    var isSearchTextEmpty: Bool {
        trimmedInput.isEmpty
    }

    var trimmedInput: String {
        viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func performSearch(with rawQuery: String) {
        let trimmed = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        viewModel.searchText = trimmed
        saveHistoryTerm(trimmed)
        viewModel.submitSearch(using: trimmed)
    }

    func saveHistoryTerm(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let normalized = trimmed.lowercased()

        if let existing = historyEntries.first(where: { $0.normalizedTerm == normalized }) {
            existing.update(with: trimmed)
        } else {
            let entry = SearchHistoryEntry(term: trimmed)
            modelContext.insert(entry)
        }

        pruneHistoryIfNeeded()
        try? modelContext.save()
    }

    func pruneHistoryIfNeeded(limit: Int = 10) {
        let ordered = historyEntries.sorted { $0.createdAt > $1.createdAt }
        guard ordered.count > limit else { return }

        for entry in ordered.dropFirst(limit) {
            modelContext.delete(entry)
        }
    }

    func deleteHistoryEntry(_ entry: SearchHistoryEntry) {
        withAnimation(.easeInOut) {
            modelContext.delete(entry)
        }
        try? modelContext.save()
    }
}

#Preview {
    SearchView()
}
