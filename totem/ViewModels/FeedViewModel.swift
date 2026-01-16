//
//  FeedViewModel.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation
import SwiftData
import Observation

@Observable
final class FeedViewModel {
    // MARK: - State
    var articles: [Article] = []
    var featuredArticle: Article?
    var selectedCategory: ArticleCategory = .forYou
    var isLoading = false
    var isRefreshing = false
    var error: String?
    var hasLoadedOnce = false

    // MARK: - Private
    private let feedAggregator = FeedAggregator.shared
    private var modelContext: ModelContext?

    // MARK: - Initialization
    init() {}

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public Methods

    @MainActor
    func loadFeed() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        // Fetch fresh articles from RSS feeds
        let freshArticles = await feedAggregator.fetchAllFeeds()

        if !freshArticles.isEmpty {
            // Persist to SwiftData
            await persistArticles(freshArticles)

            // Update display
            updateDisplayedArticles(from: freshArticles)
        } else {
            // Try to load from cache if no fresh articles
            await loadCachedArticles()

            if articles.isEmpty {
                error = "No articles found. Please check your connection and try again."
            }
        }

        hasLoadedOnce = true
        isLoading = false
    }

    @MainActor
    func refresh() async {
        isRefreshing = true

        let freshArticles = await feedAggregator.fetchAllFeeds()

        if !freshArticles.isEmpty {
            await persistArticles(freshArticles)
            updateDisplayedArticles(from: freshArticles)
            error = nil
        }

        isRefreshing = false
    }

    @MainActor
    func changeCategory(to category: ArticleCategory) async {
        // Update selected category (may already be set by binding)
        selectedCategory = category

        // Re-filter displayed articles from persisted data
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Article>(
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )

        do {
            let allArticles = try context.fetch(descriptor)
            updateDisplayedArticles(from: allArticles)
        } catch {
            print("Failed to filter articles: \(error)")
        }
    }

    @MainActor
    func toggleBookmark(for article: Article) {
        article.isBookmarked.toggle()
        saveContext()
    }

    // MARK: - Private Methods

    @MainActor
    private func updateDisplayedArticles(from allArticles: [Article]) {
        let filteredArticles: [Article]
        if selectedCategory == .forYou {
            filteredArticles = allArticles
        } else {
            filteredArticles = allArticles.filter { $0.category == selectedCategory }
        }

        articles = filteredArticles
        featuredArticle = filteredArticles.first
    }

    @MainActor
    private func loadCachedArticles() async {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Article>(
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )

        do {
            let cached = try context.fetch(descriptor)
            if !cached.isEmpty {
                updateDisplayedArticles(from: cached)
            }
        } catch {
            print("Failed to load cached articles: \(error)")
        }
    }

    @MainActor
    private func persistArticles(_ newArticles: [Article]) async {
        guard let context = modelContext else { return }

        for article in newArticles {
            // Check if article already exists
            let id = article.id
            let descriptor = FetchDescriptor<Article>(
                predicate: #Predicate<Article> { $0.id == id }
            )

            do {
                let existing = try context.fetch(descriptor)
                if existing.isEmpty {
                    context.insert(article)
                }
            } catch {
                print("Error checking existing article: \(error)")
            }
        }

        saveContext()
    }

    private func saveContext() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}

// MARK: - Preview Helper
extension FeedViewModel {
    static var preview: FeedViewModel {
        let vm = FeedViewModel()
        return vm
    }
}

// MARK: - Preview Data (only used for SwiftUI Previews)
extension Article {
    static var previewArticles: [Article] {
        [
            Article(
                id: "preview-1",
                title: "Scientists Discover New Renewable Energy Source That Could Power Millions of Homes",
                articleDescription: "A breakthrough in solar technology could revolutionize how we generate clean energy, offering hope for a sustainable future.",
                content: "Researchers at Stanford University have developed a revolutionary new type of solar cell...",
                sourceName: "Good News Network",
                sourceIcon: "sun.max.fill",
                imageURL: "https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800",
                articleURL: "https://goodnewsnetwork.org",
                publishedAt: Date().addingTimeInterval(-3600),
                category: .scienceInnovation,
                sentimentScore: 0.85
            ),
            Article(
                id: "preview-2",
                title: "Community Raises $2 Million in 48 Hours to Save Local Animal Shelter",
                articleDescription: "In an incredible show of compassion, residents came together to ensure the shelter could continue its life-saving work.",
                content: "When word spread that the Sunshine Animal Shelter was facing permanent closure...",
                sourceName: "Positive News",
                sourceIcon: "heart.fill",
                imageURL: "https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=800",
                articleURL: "https://positive.news",
                publishedAt: Date().addingTimeInterval(-7200),
                category: .actsOfKindness,
                sentimentScore: 0.92
            ),
            Article(
                id: "preview-3",
                title: "17-Year-Old Inventor Creates Device That Removes 90% of Microplastics from Ocean Water",
                articleDescription: "High school student's science fair project is now being scaled up for deployment in harbors around the world.",
                content: "What started as a high school science fair project has become one of the most promising solutions...",
                sourceName: "Upworthy",
                sourceIcon: "leaf.fill",
                imageURL: "https://images.unsplash.com/photo-1484291470158-b8f8d608850d?w=800",
                articleURL: "https://upworthy.com",
                publishedAt: Date().addingTimeInterval(-10800),
                category: .environment,
                sentimentScore: 0.88
            )
        ]
    }
}
