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
                            CategoryGridItem(category: category)
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
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }
}

struct CategoryGridItem: View {
    let category: ArticleCategory

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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

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
