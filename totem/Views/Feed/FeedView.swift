//
//  FeedView.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI
import SwiftData

struct FeedView: View {
    @Bindable var viewModel: FeedViewModel
    @Environment(\.modelContext) private var modelContext
    @Namespace private var heroNamespace
    @State private var selectedArticle: Article?

    private var remainingArticles: [Article] {
        guard viewModel.articles.count > 1 else { return [] }
        return Array(viewModel.articles.dropFirst())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Category Filter Bar - pinned style
                    CategoryFilterBar(
                        selectedCategory: $viewModel.selectedCategory,
                        onCategoryChange: { category in
                            Task {
                                await viewModel.changeCategory(to: category)
                            }
                        }
                    )
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                    // Featured Hero Card
                    if let featured = viewModel.featuredArticle {
                        HeroArticleCard(article: featured)
                            .matchedTransitionSource(
                                id: featured.id,
                                in: heroNamespace
                            )
                            .onTapGesture {
                                selectedArticle = featured
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                    }

                    // Latest Stories Header
                    if !remainingArticles.isEmpty {
                        SectionHeader(title: "Latest Stories")
                            .padding(.bottom, 8)
                    }

                    // Article List
                    LazyVStack(spacing: 12) {
                        ForEach(remainingArticles) { article in
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

                    // Loading indicator
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(40)
                    }

                    // Bottom padding for tab bar
                    Spacer()
                        .frame(height: 20)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationTitle("Totem")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
                    .navigationTransition(.zoom(sourceID: article.id, in: heroNamespace))
            }
            .overlay {
                if viewModel.articles.isEmpty && !viewModel.isLoading && viewModel.hasLoadedOnce {
                    EmptyCategoryView(category: viewModel.selectedCategory)
                }
            }
        }
        .task {
            await viewModel.loadFeed()
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Empty State
struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow.gradient)

            Text("Loading Positivity")
                .font(.title2)
                .fontWeight(.bold)

            Text("Fetching uplifting stories for you...")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            ProgressView()
                .padding(.top, 8)
        }
        .padding(40)
    }
}

// MARK: - Empty Category State
struct EmptyCategoryView: View {
    let category: ArticleCategory

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: category.icon)
                .font(.system(size: 50))
                .foregroundStyle(category.primaryColor)

            Text("No \(category.displayName) Stories")
                .font(.title3)
                .fontWeight(.bold)

            Text("We haven't found any \(category.displayName.lowercased()) articles yet.\nPull down to refresh or try another category.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(40)
    }
}

#Preview {
    FeedView(viewModel: .preview)
        .modelContainer(for: Article.self, inMemory: true)
}
