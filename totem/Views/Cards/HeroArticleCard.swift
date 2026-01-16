//
//  HeroArticleCard.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI

struct HeroArticleCard: View {
    let article: Article
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with gradient overlay
            ZStack(alignment: .bottomLeading) {
                // Article Image or Gradient Placeholder
                Group {
                    if let imageURL = article.imageURL,
                       let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                placeholderGradient
                            case .empty:
                                ZStack {
                                    placeholderGradient
                                    ProgressView()
                                        .tint(.white)
                                }
                            @unknown default:
                                placeholderGradient
                            }
                        }
                    } else {
                        placeholderGradient
                    }
                }
                .frame(height: 240)
                .clipped()

                // Gradient overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Category pill
                HStack(spacing: 4) {
                    Image(systemName: article.category.icon)
                        .font(.caption2)
                    Text(article.category.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(16)
            }

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(3)
                    .foregroundStyle(.primary)

                if let description = article.articleDescription {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Source and time
                HStack(spacing: 8) {
                    if let icon = article.sourceIcon {
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundStyle(article.category.primaryColor)
                    }

                    Text(article.sourceName)
                        .font(.caption)
                        .fontWeight(.medium)

                    Text("·")
                        .foregroundStyle(.tertiary)

                    Text(article.relativeTimeString)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Positivity indicator
                    PositivityBadge(score: article.sentimentScore)
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.3), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity) {
            // Never completes
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(article.title). From \(article.sourceName). \(article.relativeTimeString)")
        .accessibilityHint("Double tap to read the full article")
    }

    private var placeholderGradient: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ],
            colors: [
                article.category.gradient[0],
                article.category.gradient[1],
                article.category.gradient[0],
                article.category.gradient[1],
                .white.opacity(0.8),
                article.category.gradient[0],
                article.category.gradient[0],
                article.category.gradient[1],
                article.category.gradient[1]
            ]
        )
        .overlay {
            Image(systemName: article.category.icon)
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Positivity Badge
struct PositivityBadge: View {
    let score: Double

    private var displayScore: Int {
        // Convert -1 to 1 range to 0 to 100
        Int(((score + 1) / 2) * 100)
    }

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "sparkles")
                .font(.caption2)
            Text("\(displayScore)%")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundStyle(.green)
    }
}

#Preview {
    VStack {
        HeroArticleCard(article: Article.previewArticles[0])
            .padding()
    }
    .background(Color(.systemGroupedBackground))
}
