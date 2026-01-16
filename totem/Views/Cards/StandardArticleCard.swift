//
//  StandardArticleCard.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI

struct StandardArticleCard: View {
    let article: Article
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            Group {
                if let imageURL = article.imageURL,
                   let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            thumbnailPlaceholder
                        @unknown default:
                            thumbnailPlaceholder
                        }
                    }
                } else {
                    thumbnailPlaceholder
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Category
                Text(article.category.displayName.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(article.category.primaryColor)

                // Title
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Spacer()

                // Meta
                HStack(spacing: 6) {
                    Text(article.sourceName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("·")
                        .foregroundStyle(.tertiary)

                    Text(article.relativeTimeString)
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Spacer()

                    if article.isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.3), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity) {
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(article.title)
        .accessibilityHint("Double tap to read article from \(article.sourceName)")
    }

    private var thumbnailPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                LinearGradient(
                    colors: article.category.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: article.category.icon)
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
            }
    }
}

#Preview {
    VStack(spacing: 12) {
        StandardArticleCard(article: Article.previewArticles[1])
        StandardArticleCard(article: Article.previewArticles[2])
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
