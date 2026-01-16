//
//  BookmarksView.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI
import SwiftData

struct BookmarksView: View {
    @Query(filter: #Predicate<Article> { $0.isBookmarked == true },
           sort: \Article.publishedAt,
           order: .reverse)
    private var bookmarkedArticles: [Article]

    @Namespace private var heroNamespace
    @State private var selectedArticle: Article?

    var body: some View {
        NavigationStack {
            Group {
                if bookmarkedArticles.isEmpty {
                    EmptyBookmarksView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(bookmarkedArticles) { article in
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
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
                    .navigationTransition(.zoom(sourceID: article.id, in: heroNamespace))
            }
        }
    }
}

struct EmptyBookmarksView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Saved Articles")
                .font(.title2)
                .fontWeight(.bold)

            Text("Bookmark articles to read later\nand they'll appear here.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    BookmarksView()
        .modelContainer(for: Article.self, inMemory: true)
}
