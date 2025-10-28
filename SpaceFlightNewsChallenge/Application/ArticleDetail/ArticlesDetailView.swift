//
//  ArticlesDetailView.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 27/10/2025.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    
    init(article: Article) {
        self.article = article
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16 ) {
                articleImage
                
                VStack(alignment: .leading, spacing: 12) {
                    articleTitle
                    articleData
                    articleSummary
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

private extension ArticleDetailView {
    var articleImage: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: article.imageUrl)) { phase in
                switch phase {
                case .empty:
                    placeholderView
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: 300)
                        .clipped()
                case .failure:
                    placeholderIcon
                @unknown default:
                    placeholderView
                }
            }
        }
        .frame(height: 300)
    }
    
    var placeholderBackground: Color {
        Color.white
    }

    var placeholderView: some View {
        placeholderBackground
            .overlay(
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            )
    }

    var placeholderIcon: some View {
        placeholderBackground
            .overlay(
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(16)
                    .foregroundStyle(.secondary)
            )
    }
}

private extension ArticleDetailView {
    var articleTitle: some View {
        Text(article.title)
            .font(.title)
    }
}

private extension ArticleDetailView {
    var articleData: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(article.newsSite)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(article.authors.first?.name ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private extension ArticleDetailView {
    var articleSummary: some View {
        Text(article.summary)
            .font(.body)
    }
}

#Preview {
    ArticleDetailView(article: Article(
        id: 33643,
        title: "H3 launches first HTV-X cargo spacecraft",
        url: "https://spacenews.com/h3-launches-first-htv-x-cargo-spacecraft/",
        imageUrl: "https://i0.wp.com/spacenews.com/wp-content/uploads/2025/10/h3-htvx1.jpeg?fit=1024%2C603&ssl=1",
        newsSite: "SpaceNews",
        summary: "Japan launched the first of a new generation of cargo spacecraft to the International Space Station, with potential applications beyond low Earth orbit.\r\nThe post H3 launches first HTV-X cargo spacecraft appeared first on SpaceNews.",
        publishedAt: "2025-10-26T14:22:34Z",
        updatedAt: "2025-10-26T14:30:27.289010Z", authors: [ArticleAuthor(name: "Jeff Foust")]
    ))
}
