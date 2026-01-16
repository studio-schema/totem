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

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    // Category Filter Bar
                    Section {
                        CategoryFilterBar(
                            selectedCategory: $viewModel.selectedCategory,
                            onCategoryChange: { category in
                                Task {
                                    await viewModel.changeCategory(to: category)
                                }
                            }
                        )
                        .padding(.vertical, 12)
                    }

                    // Featured Hero Card
                    if let featured = viewModel.featuredArticle {
                        Section {
                            HeroArticleCard(article: featured)
                                .matchedTransitionSource(
                                    id: featured.id,
                                    in: heroNamespace
                                )
                                .onTapGesture {
                                    selectedArticle = featured
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 24)
                        }
                    }

                    // Article List
                    Section {
                        ForEach(Array(viewModel.articles.dropFirst())) { article in
                            StandardArticleCard(article: article)
                                .matchedTransitionSource(
                                    id: article.id,
                                    in: heroNamespace
                                )
                                .onTapGesture {
                                    selectedArticle = article
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                        }
                    } header: {
                        if !viewModel.articles.isEmpty {
                            SectionHeader(title: "Latest Stories")
                                .background(.ultraThinMaterial)
                        }
                    }

                    // Loading indicator
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(40)
                    }
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
                if viewModel.articles.isEmpty && !viewModel.isLoading {
                    EmptyFeedView()
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

#Preview {
    FeedView(viewModel: .preview)
        .modelContainer(for: Article.self, inMemory: true)
}
