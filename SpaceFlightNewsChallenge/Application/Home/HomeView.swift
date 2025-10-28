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
            let repository = AppDependencies.shared.articlesRepository
            _viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: -25) {
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

extension HomeView {
    var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            searchBar
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
            Button {
                viewModel.openSearchScreen()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray.opacity(0.7))

                    Text(trimmedSearchQuery.isEmpty ? "Buscar en Space Flight News" : trimmedSearchQuery)
                        .foregroundStyle(trimmedSearchQuery.isEmpty ? Color.gray.opacity(0.7) : Color.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)

            if viewModel.isShowingSearchResults {
                Button {
                    viewModel.clearSearch()
                } label: {
                    Text("Limpiar")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(ColorsHelper.mainDark)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.isShowingSearchResults)
    }

    var articlesList: some View {
        
        VStack {
            headerTitle
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
            List {
                if viewModel.isLoading && viewModel.articles.isEmpty {
                    ForEach(0..<5, id: \.self) { _ in
                        ArticleRowSkeleton()
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 16, trailing: 16))
                            .listRowBackground(Color.clear)
                    }
                } else if let error = viewModel.listError, viewModel.articles.isEmpty {
                    ErrorPlaceholderView(
                        message: error.message,
                        retryAction: {
                            Task {
                                await viewModel.loadArticles()
                            }
                        }
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16))
                    .listRowBackground(Color.clear)
                } else if viewModel.articles.isEmpty {
                    Text("Aun no hay articulos")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16))
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.articles) { article in
                        Button {
                            viewModel.didSelect(article: article)
                        } label: {
                            ArticleRow(article: article)
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 16, trailing: 16))
                        .listRowBackground(Color.clear)
                        .task {
                            guard article == viewModel.articles.last else { return }
                            await viewModel.loadMoreArticles()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.white)
        }
    }

    var headerTitle: some View {
        Group {
            if viewModel.isShowingSearchResults {
                searchResultsHeader
            } else {
                Text("Últimos artículos")
                    .font(.title)
            }
        }
    }

    var searchResultsHeader: some View {
        let trimmedQuery = trimmedSearchQuery
        let titleText = Text("Resultados de buscar: ")
            .font(.title2)
            .fontWeight(.semibold)
        let queryText = Text(trimmedQuery.isEmpty ? "—" : trimmedQuery)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(ColorsHelper.grayLight)

        return (titleText + queryText)
            .lineLimit(2)
            .minimumScaleFactor(0.9)
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
    }

    var trimmedSearchQuery: String {
        viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct ArticleRowSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 16)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 160, height: 14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .redacted(reason: .placeholder)
        .shimmeringPlaceholder()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ErrorPlaceholderView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(ColorsHelper.mainDark.opacity(0.8))

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Button(action: retryAction) {
                Text("Recargar")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(ColorsHelper.mainDark)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 24)
    }
}

private struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let size = geometry.size
                    let gradient = LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.55),
                            Color.white.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    Rectangle()
                        .fill(gradient)
                        .rotationEffect(.degrees(20))
                        .frame(width: size.width * 2, height: size.height * 1.4)
                        .offset(x: size.width * phase)
                }
                .mask(content)
                .allowsHitTesting(false)
            }
            .onAppear {
                phase = -1
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

private extension View {
    func shimmeringPlaceholder() -> some View {
        modifier(ShimmerEffect())
    }
}
