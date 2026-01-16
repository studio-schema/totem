//
//  SearchView.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var searchText = ""
    @Query(sort: \Article.publishedAt, order: .reverse)
    private var allArticles: [Article]

    @Namespace private var heroNamespace
    @State private var selectedArticle: Article?

    private var filteredArticles: [Article] {
        if searchText.isEmpty {
            return []
        }
        return allArticles.filter { article in
            article.title.localizedCaseInsensitiveContains(searchText) ||
            (article.articleDescription?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            article.sourceName.localizedCaseInsensitiveContains(searchText) ||
            article.category.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    DiscoverView()
                } else if filteredArticles.isEmpty {
                    NoResultsView(searchText: searchText)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredArticles) { article in
                                StandardArticleCard(article: article)
                                    .matchedTransitionSource(
                                        id: article.id,
                                        in: heroNamespace
                                    )
                                    .onTapGesture {
                                        selectedArticle = article
                                    }
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search positive news")
            .navigationDestination(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
                    .navigationTransition(.zoom(sourceID: article.id, in: heroNamespace))
            }
        }
    }
}

struct DiscoverView: View {
    @Query(sort: \Article.publishedAt, order: .reverse)
    private var allArticles: [Article]

    @State private var selectedCategory: ArticleCategory?
    @State private var selectedSource: NewsSource?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Categories Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Browse Categories")
                        .font(.headline)
                        .padding(.horizontal, 16)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(ArticleCategory.allCases.filter { $0 != .forYou }) { category in
                            CategoryGridItem(category: category, articleCount: countArticles(for: category))
                                .onTapGesture {
                                    selectedCategory = category
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Sources Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Our Sources")
                        .font(.headline)
                        .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(NewsSource.defaultSources) { source in
                                SourceCard(source: source)
                                    .onTapGesture {
                                        selectedSource = source
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // Trending Section
                if !allArticles.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Trending Now")
                            .font(.headline)
                            .padding(.horizontal, 16)

                        ForEach(allArticles.prefix(3)) { article in
                            TrendingArticleRow(article: article)
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .sheet(item: $selectedCategory) { category in
            CategoryArticlesView(category: category)
        }
        .sheet(item: $selectedSource) { source in
            SourceArticlesView(source: source)
        }
    }

    private func countArticles(for category: ArticleCategory) -> Int {
        allArticles.filter { $0.category == category }.count
    }
}

// MARK: - Category Articles View
struct CategoryArticlesView: View {
    let category: ArticleCategory
    @Query(sort: \Article.publishedAt, order: .reverse)
    private var allArticles: [Article]
    @Environment(\.dismiss) private var dismiss
    @Namespace private var heroNamespace
    @State private var selectedArticle: Article?

    private var filteredArticles: [Article] {
        allArticles.filter { $0.category == category }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredArticles.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: category.icon)
                            .font(.system(size: 50))
                            .foregroundStyle(category.primaryColor)

                        Text("No \(category.displayName) Articles")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Check back later for more uplifting content.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredArticles) { article in
                                StandardArticleCard(article: article)
                                    .matchedTransitionSource(id: article.id, in: heroNamespace)
                                    .onTapGesture {
                                        selectedArticle = article
                                    }
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle(category.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationDestination(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
                    .navigationTransition(.zoom(sourceID: article.id, in: heroNamespace))
            }
        }
    }
}

// MARK: - Source Articles View
struct SourceArticlesView: View {
    let source: NewsSource
    @Query(sort: \Article.publishedAt, order: .reverse)
    private var allArticles: [Article]
    @Environment(\.dismiss) private var dismiss
    @Namespace private var heroNamespace
    @State private var selectedArticle: Article?

    private var filteredArticles: [Article] {
        allArticles.filter { $0.sourceName == source.name }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredArticles.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: source.icon)
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)

                        Text("No Articles from \(source.name)")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Check back later for more content.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredArticles) { article in
                                StandardArticleCard(article: article)
                                    .matchedTransitionSource(id: article.id, in: heroNamespace)
                                    .onTapGesture {
                                        selectedArticle = article
                                    }
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle(source.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationDestination(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
                    .navigationTransition(.zoom(sourceID: article.id, in: heroNamespace))
            }
        }
    }
}

// MARK: - Trending Article Row
struct TrendingArticleRow: View {
    let article: Article

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(article.category.displayName.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(article.category.primaryColor)

                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                Text(article.sourceName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Category Grid Item
struct CategoryGridItem: View {
    let category: ArticleCategory
    var articleCount: Int = 0

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    LinearGradient(
                        colors: category.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())

            Text(category.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)

            if articleCount > 0 {
                Text("\(articleCount) articles")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Source Card
struct SourceCard: View {
    let source: NewsSource

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: source.icon)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(Color(.systemGray5))
                .clipShape(Circle())

            Text(source.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 100)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - No Results View
struct NoResultsView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No Results")
                .font(.title2)
                .fontWeight(.bold)

            Text("No positive news found for \"\(searchText)\"")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    SearchView()
        .modelContainer(for: Article.self, inMemory: true)
}
