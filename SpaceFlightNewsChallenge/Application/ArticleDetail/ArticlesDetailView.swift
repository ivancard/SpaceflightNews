//
//  ArticlesDetailView.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 27/10/2025.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.openURL) private var openURL
    
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
                    articleLinkSection
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
            if !formattedPublishedDate.isEmpty {
                Text("Publicado el \(formattedPublishedDate)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Text(primaryAuthor.isEmpty ? "Autor desconocido" : primaryAuthor)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private extension ArticleDetailView {
    var articleSummary: some View {
        let trimmedSummary = article.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        return Group {
            if trimmedSummary.isEmpty {
                Text("Este artículo no tiene un resumen disponible.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            } else {
                Text(trimmedSummary)
                    .font(.body)
            }
        }
    }
}

private extension ArticleDetailView {
    var articleLinkSection: some View {
        Group {
            if let destinationURL = URL(string: article.url) {
                Button {
                    openURL(destinationURL)
                } label: {
                    Label("Leer artículo en el sitio", systemImage: "safari")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3)
                }
                .buttonStyle(.borderedProminent)
                .tint(ColorsHelper.mainDark)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.top, 22)
            } else {
                Text("El enlace original no está disponible.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private extension ArticleDetailView {
    var primaryAuthor: String {
        article.authors.first?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    var formattedPublishedDate: String {
        if let date = ArticleDetailView.isoFormatterWithFractional.date(from: article.publishedAt) {
            return ArticleDetailView.displayFormatter.string(from: date)
        }
        if let date = ArticleDetailView.isoFormatter.date(from: article.publishedAt) {
            return ArticleDetailView.displayFormatter.string(from: date)
        }
        return ""
    }
    
    static let isoFormatterWithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
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
