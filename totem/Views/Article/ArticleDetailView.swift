//
//  ArticleDetailView.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @State private var scrollOffset: CGFloat = 0
    @State private var isBookmarked: Bool
    @State private var showSafari = false
    @Environment(\.dismiss) private var dismiss

    init(article: Article) {
        self.article = article
        _isBookmarked = State(initialValue: article.isBookmarked)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Image with parallax
                    ParallaxHeader(
                        imageURL: article.imageURL,
                        category: article.category,
                        height: 300,
                        scrollOffset: scrollOffset
                    )

                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Category and reading time
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: article.category.icon)
                                    .font(.caption)
                                Text(article.category.displayName)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: article.category.gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(Capsule())

                            Spacer()

                            Text("\(article.estimatedReadingTime) min read")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Title
                        Text(article.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .fontDesign(.serif)

                        // Source and date
                        HStack(spacing: 12) {
                            if let icon = article.sourceIcon {
                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(article.category.primaryColor)
                                    .frame(width: 32, height: 32)
                                    .background(article.category.primaryColor.opacity(0.1))
                                    .clipShape(Circle())
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(article.sourceName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Text(article.publishedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if let author = article.author {
                                Text("By \(author)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Divider()
                            .padding(.vertical, 8)

                        // Article content
                        if let content = article.content, !content.isEmpty {
                            Text(content)
                                .font(.body)
                                .fontDesign(.serif)
                                .lineSpacing(8)
                        } else if let description = article.articleDescription {
                            Text(description)
                                .font(.body)
                                .fontDesign(.serif)
                                .lineSpacing(8)
                        }

                        // Read Full Article button - always show
                        Button {
                            showSafari = true
                        } label: {
                            HStack {
                                Text("Read Full Article")
                                Image(systemName: "safari")
                            }
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: article.category.gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 16)

                        // Positivity score card
                        PositivityScoreCard(article: article)
                            .padding(.top, 24)
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .named("scroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        isBookmarked.toggle()
                        // In a real app, persist this
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    }

                    ShareLink(
                        item: URL(string: article.articleURL)!,
                        subject: Text(article.title)
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showSafari) {
            if let url = URL(string: article.articleURL) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Parallax Header
struct ParallaxHeader: View {
    let imageURL: String?
    let category: ArticleCategory
    let height: CGFloat
    let scrollOffset: CGFloat

    private var parallaxOffset: CGFloat {
        scrollOffset > 0 ? -scrollOffset / 2 : 0
    }

    private var scale: CGFloat {
        scrollOffset > 0 ? 1 + scrollOffset / 500 : 1
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let urlString = imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            gradientPlaceholder
                        @unknown default:
                            gradientPlaceholder
                        }
                    }
                } else {
                    gradientPlaceholder
                }
            }
            .frame(
                width: geometry.size.width,
                height: height + (scrollOffset > 0 ? scrollOffset : 0)
            )
            .offset(y: parallaxOffset)
            .scaleEffect(scale)
        }
        .frame(height: height)
        .clipped()
    }

    private var gradientPlaceholder: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ],
            colors: [
                category.gradient[0],
                category.gradient[1],
                category.gradient[0],
                category.gradient[1],
                .white.opacity(0.5),
                category.gradient[0],
                category.gradient[0],
                category.gradient[1],
                category.gradient[1]
            ]
        )
        .overlay {
            Image(systemName: category.icon)
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.3))
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Positivity Score Card
struct PositivityScoreCard: View {
    let article: Article

    private var displayScore: Int {
        Int(((article.sentimentScore + 1) / 2) * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
                Text("Positivity Score")
                    .font(.headline)
            }

            HStack(spacing: 20) {
                // Score circle
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.2), lineWidth: 6)

                    Circle()
                        .trim(from: 0, to: Double(displayScore) / 100)
                        .stroke(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    Text("\(displayScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
                .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text("This story passed our positivity filter")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("Verified for uplifting content using AI sentiment analysis")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        ArticleDetailView(article: Article.previewArticles[0])
    }
}
