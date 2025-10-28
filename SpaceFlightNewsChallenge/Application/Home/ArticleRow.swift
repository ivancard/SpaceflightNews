//
//  ArticleRow.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 26/10/2025.
//

import SwiftUI

struct ArticleRow: View {
    let article: Article

    init(article: Article) {
        self.article = article
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            articleImage
            
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                HStack(spacing: 12) {
                    Text(article.newsSite)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(ColorsHelper.mainDark)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Text(formattedDate)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color.black.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private extension ArticleRow {
    var articleImage: some View {
        AsyncImage(url: URL(string: article.imageUrl)) { phase in
            switch phase {
            case .empty:
                placeholderView
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                placeholderIcon
            @unknown default:
                placeholderView
            }
        }
        .frame(width: 88, height: 88)
        .background(placeholderBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .clipped()
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
    
    var formattedDate: String {
        if let date = ArticleRow.isoFormatterWithFractional.date(from: article.publishedAt) {
            return ArticleRow.displayFormatter.string(from: date)
        }
        if let date = ArticleRow.isoFormatter.date(from: article.publishedAt) {
            return ArticleRow.displayFormatter.string(from: date)
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
    ArticleRow(
        article: Article(
            id: 1,
            title: "Astrobotic delays Griffin-1 lander mission to mid-2026",
            url: "https://example.com",
            imageUrl: "https://picsum.photos/200",
            newsSite: "SpaceNews",
            summary: "Summary",
            publishedAt: "2025-10-26T14:22:34Z",
            updatedAt: "2025-10-26T14:30:27.289010Z",
            authors: [ArticleAuthor(name: "Jeff Foust")]
        )
    )
}
