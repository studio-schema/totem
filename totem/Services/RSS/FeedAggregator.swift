//
//  FeedAggregator.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation

actor FeedAggregator {
    static let shared = FeedAggregator()

    private let parser = RSSParser()
    private let sentimentAnalyzer = SentimentAnalyzer.shared
    private let positivityFilter = PositivityFilter.shared

    private init() {}

    func fetchAllFeeds(sources: [NewsSource] = NewsSource.defaultSources) async -> [Article] {
        var allArticles: [Article] = []

        await withTaskGroup(of: [Article].self) { group in
            for source in sources where source.isEnabled {
                group.addTask {
                    await self.fetchFeed(from: source)
                }
            }

            for await articles in group {
                allArticles.append(contentsOf: articles)
            }
        }

        // Sort by date, newest first
        allArticles.sort { $0.publishedAt > $1.publishedAt }

        // Filter for positivity
        let filteredArticles = await positivityFilter.filter(allArticles)

        return filteredArticles
    }

    func fetchFeed(from source: NewsSource) async -> [Article] {
        do {
            let items = try await parser.fetchAndParse(from: source.feedURL)

            var articles: [Article] = []

            for item in items {
                let article = await convertToArticle(item: item, source: source)
                articles.append(article)
            }

            return articles
        } catch {
            print("Failed to fetch feed from \(source.name): \(error.localizedDescription)")
            return []
        }
    }

    private func convertToArticle(item: RSSParser.RSSItem, source: NewsSource) async -> Article {
        // Determine category based on content
        let category = await determineCategory(
            title: item.title,
            description: item.description,
            defaultCategory: source.defaultCategory
        )

        // Calculate sentiment score
        let sentimentScore = await sentimentAnalyzer.analyze(
            text: "\(item.title). \(item.description)"
        )

        let article = Article(
            id: generateID(from: item.link),
            title: item.title,
            articleDescription: item.description,
            content: item.content,
            author: item.author,
            sourceName: source.name,
            sourceIcon: source.icon,
            imageURL: item.imageURL,
            articleURL: item.link,
            publishedAt: parseDate(item.pubDate),
            category: category,
            keywords: extractKeywords(from: item.title + " " + item.description),
            sentimentScore: sentimentScore
        )

        article.isVerifiedPositive = sentimentScore >= 0

        return article
    }

    private func determineCategory(
        title: String,
        description: String,
        defaultCategory: ArticleCategory
    ) async -> ArticleCategory {
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
