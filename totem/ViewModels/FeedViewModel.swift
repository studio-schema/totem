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

    // MARK: - Private
    private let feedAggregator = FeedAggregator.shared
    private var modelContext: ModelContext?

    // MARK: - Initialization
    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public Methods

    @MainActor
    func loadFeed() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        do {
            // First, load cached articles from SwiftData
            await loadCachedArticles()

            // Then fetch fresh articles from RSS feeds
            let freshArticles = await feedAggregator.fetchAllFeeds()

            // Filter by category if not "For You"
            let filteredArticles: [Article]
            if selectedCategory == .forYou {
                filteredArticles = freshArticles
            } else {
                filteredArticles = freshArticles.filter { $0.category == selectedCategory }
            }

            // Update state
            articles = filteredArticles
            featuredArticle = filteredArticles.first

            // Persist to SwiftData
            await persistArticles(freshArticles)

        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func refresh() async {
        isRefreshing = true
        await loadFeed()
        isRefreshing = false
    }

    @MainActor
    func changeCategory(to category: ArticleCategory) async {
        guard category != selectedCategory else { return }

        selectedCategory = category

        if category == .forYou {
            // Show all articles
            await loadFeed()
        } else {
            // Filter current articles by category
            let allArticles = await feedAggregator.fetchAllFeeds()
            articles = allArticles.filter { $0.category == category }
            featuredArticle = articles.first
        }
    }

    @MainActor
    func toggleBookmark(for article: Article) {
        article.isBookmarked.toggle()
        saveChanges()
    }

    // MARK: - Private Methods

    @MainActor
    private func loadCachedArticles() async {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Article>(
            predicate: #Predicate<Article> { article in
                article.isVerifiedPositive == true
            },
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )

        do {
            let cached = try context.fetch(descriptor)
            if !cached.isEmpty && articles.isEmpty {
                articles = cached
                featuredArticle = cached.first
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

        saveChanges()
    }

    private func saveChanges() {
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
        vm.articles = Article.previewArticles
        vm.featuredArticle = Article.previewArticles.first
        return vm
    }
}

// MARK: - Preview Data
extension Article {
    static var previewArticles: [Article] {
        [
            Article(
                id: "1",
                title: "Scientists Discover New Renewable Energy Source That Could Power Millions",
                articleDescription: "A breakthrough in solar technology could revolutionize how we generate clean energy, offering hope for a sustainable future.",
                sourceName: "Good News Network",
                sourceIcon: "sun.max.fill",
                imageURL: "https://picsum.photos/800/600",
                articleURL: "https://example.com/1",
                publishedAt: Date().addingTimeInterval(-3600),
                category: .scienceInnovation,
                sentimentScore: 0.8
            ),
            Article(
                id: "2",
                title: "Community Raises $1 Million to Save Local Animal Shelter",
                articleDescription: "In an incredible show of compassion, residents came together to ensure the shelter could continue its life-saving work.",
                sourceName: "Positive News",
                sourceIcon: "heart.fill",
                imageURL: "https://picsum.photos/800/601",
                articleURL: "https://example.com/2",
                publishedAt: Date().addingTimeInterval(-7200),
                category: .actsOfKindness,
                sentimentScore: 0.9
            ),
            Article(
                id: "3",
                title: "Teen Inventor Creates Device to Help Clean Ocean Plastic",
                articleDescription: "A 17-year-old's innovative solution is already removing tons of plastic from our oceans.",
                sourceName: "Upworthy",
                sourceIcon: "leaf.fill",
                imageURL: "https://picsum.photos/800/602",
                articleURL: "https://example.com/3",
                publishedAt: Date().addingTimeInterval(-10800),
                category: .environment,
                sentimentScore: 0.85
            ),
            Article(
                id: "4",
                title: "First-Generation College Student Wins Full Scholarship to Dream School",
                articleDescription: "Against all odds, Maria overcame incredible challenges to achieve her educational dreams.",
                sourceName: "Good Good Good",
                sourceIcon: "star.fill",
                imageURL: "https://picsum.photos/800/603",
                articleURL: "https://example.com/4",
                publishedAt: Date().addingTimeInterval(-14400),
                category: .inspiringStories,
                sentimentScore: 0.95
            )
        ]
    }
}
