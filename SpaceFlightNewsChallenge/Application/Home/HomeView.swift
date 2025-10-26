//
//  HomeView.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 24/10/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    @MainActor
    init(viewModel: HomeViewModel? = nil) {
        if let viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            let repository = ArticlesRepository(apiClient: APIClient())
            _viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                articlesList
            }
        }
        .task {
            await viewModel.loadArticles()
        }
    }
}

#Preview {
    HomeView()
}

private extension HomeView {
    var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Space Flight News")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .padding(.top, 44)

            searchBar
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(spaceIndigo)
        .ignoresSafeArea(edges: .top)
    }

    var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.gray.opacity(0.7))

            TextField("Buscar en Space Flight News", text: $viewModel.searchText)
                .textInputAutocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }

    var articlesList: some View {
        List {
            if viewModel.articles.isEmpty {
                Text("Aun no hay articulos")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.articles) { article in
                    Text(article.title)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.white)
    }

    var spaceIndigo: Color {
        Color(red: 0x21/255, green: 0x02/255, blue: 0x4F/255)
    }
}
