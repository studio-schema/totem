//
//  FeedAggregator.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation

// Simple data struct for transferring RSS data (Sendable)
struct RSSArticleData: Sendable {
    let title: String
    let description: String
    let link: String
    let imageURL: String?
    let author: String?
    let content: String?
    let pubDate: String
    let sourceName: String
    let sourceIcon: String
    let defaultCategoryRaw: String
}

@MainActor
final class FeedAggregator {
    static let shared = FeedAggregator()

    private let sentimentAnalyzer = SentimentAnalyzer.shared
    private let positivityFilter = PositivityFilter.shared

    private init() {}

    func fetchAllFeeds(sources: [NewsSource] = NewsSource.defaultSources) async -> [Article] {
        var allArticleData: [RSSArticleData] = []

        // Fetch from all sources concurrently
        await withTaskGroup(of: [RSSArticleData].self) { group in
            for source in sources where source.isEnabled {
                group.addTask { [source] in
                    await self.fetchFeedData(from: source)
                }
            }

            for await data in group {
                allArticleData.append(contentsOf: data)
            }
        }

        // Convert to Articles on main actor
        var articles: [Article] = []
        for data in allArticleData {
            let article = await convertToArticle(data: data)
            articles.append(article)
        }

        // Sort by date, newest first
        articles.sort { $0.publishedAt > $1.publishedAt }

        // Filter for positivity
        let filteredArticles = positivityFilter.filter(articles)

        return filteredArticles
    }

    nonisolated func fetchFeedData(from source: NewsSource) async -> [RSSArticleData] {
        do {
            let parser = RSSParser()
            let items = try await parser.fetchAndParse(from: source.feedURL)

            let data = items.map { item in
                RSSArticleData(
                    title: item.title,
                    description: item.description,
                    link: item.link,
                    imageURL: item.imageURL,
                    author: item.author,
                    content: item.content,
                    pubDate: item.pubDate,
                    sourceName: source.name,
                    sourceIcon: source.icon,
                    defaultCategoryRaw: source.defaultCategoryRaw
                )
            }

            print("Fetched \(data.count) articles from \(source.name)")
            return data
        } catch {
            print("Failed to fetch feed from \(source.name): \(error.localizedDescription)")
            return []
        }
    }

    private func convertToArticle(data: RSSArticleData) async -> Article {
        let defaultCategory = ArticleCategory(rawValue: data.defaultCategoryRaw) ?? .goodNews

        // Determine category based on content
        let category = determineCategory(
            title: data.title,
            description: data.description,
            defaultCategory: defaultCategory
        )

        // Calculate sentiment score
        let sentimentScore = await sentimentAnalyzer.analyze(
            text: "\(data.title). \(data.description)"
        )

        let article = Article(
            id: generateID(from: data.link),
            title: data.title,
            articleDescription: data.description,
            content: data.content,
            author: data.author,
            sourceName: data.sourceName,
            sourceIcon: data.sourceIcon,
            imageURL: data.imageURL,
            articleURL: data.link,
            publishedAt: parseDate(data.pubDate),
            category: category,
            keywords: extractKeywords(from: data.title + " " + data.description),
            sentimentScore: sentimentScore
        )

        article.isVerifiedPositive = sentimentScore >= 0

        return article
    }

    private func determineCategory(
        title: String,
        description: String,
        defaultCategory: ArticleCategory
    ) -> ArticleCategory {
        let text = (title + " " + description).lowercased()

        // Check each category's keywords
        var bestMatch: ArticleCategory = defaultCategory
        var highestScore = 0

        for category in ArticleCategory.allCases where category != .forYou {
            let matchCount = category.keywords.reduce(0) { count, keyword in
                count + (text.contains(keyword.lowercased()) ? 1 : 0)
            }

            if matchCount > highestScore {
                highestScore = matchCount
                bestMatch = category
            }
        }

        return highestScore > 0 ? bestMatch : defaultCategory
    }

    private func generateID(from url: String) -> String {
        // Create a stable ID from the URL
        let data = Data(url.utf8)
        return data.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .prefix(64)
            .description
    }

    private func parseDate(_ dateString: String) -> Date {
        let formatters: [DateFormatter] = [
            {
                let f = DateFormatter()
                f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                f.locale = Locale(identifier: "en_US_POSIX")
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                f.locale = Locale(identifier: "en_US_POSIX")
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                f.locale = Locale(identifier: "en_US_POSIX")
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
                f.locale = Locale(identifier: "en_US_POSIX")
                return f
            }()
        ]

        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        // Fallback to now if parsing fails
        return Date()
    }

    private func extractKeywords(from text: String) -> [String] {
        let words = text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 3 }

        // Remove common words
        let stopWords = Set(["this", "that", "with", "from", "have", "been", "were", "they", "their", "about", "would", "could", "should", "which", "there", "being", "other"])

        return Array(Set(words.filter { !stopWords.contains($0) })).prefix(10).map { $0 }
    }
}
