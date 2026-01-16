//
//  Article.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation
import SwiftData

@Model
final class Article {
    @Attribute(.unique) var id: String

    // Core content
    var title: String
    var articleDescription: String?
    var content: String?
    var author: String?
    var sourceName: String
    var sourceIcon: String?

    // Media
    var imageURL: String?
    var articleURL: String

    // Metadata
    var publishedAt: Date
    var fetchedAt: Date

    // Classification
    var categoryRaw: String
    var keywords: [String]

    // Sentiment scores
    var sentimentScore: Double
    var isVerifiedPositive: Bool

    // User interaction
    var isBookmarked: Bool
    var isRead: Bool
    var readAt: Date?

    // Offline support
    @Attribute(.externalStorage) var cachedImageData: Data?
    var isCachedForOffline: Bool

    var category: ArticleCategory {
        get { ArticleCategory(rawValue: categoryRaw) ?? .goodNews }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        id: String,
        title: String,
        articleDescription: String? = nil,
        content: String? = nil,
        author: String? = nil,
        sourceName: String,
        sourceIcon: String? = nil,
        imageURL: String? = nil,
        articleURL: String,
        publishedAt: Date,
        category: ArticleCategory,
        keywords: [String] = [],
        sentimentScore: Double = 0.5
    ) {
        self.id = id
        self.title = title
        self.articleDescription = articleDescription
        self.content = content
        self.author = author
        self.sourceName = sourceName
        self.sourceIcon = sourceIcon
        self.imageURL = imageURL
        self.articleURL = articleURL
        self.publishedAt = publishedAt
        self.fetchedAt = Date()
        self.categoryRaw = category.rawValue
        self.keywords = keywords
        self.sentimentScore = sentimentScore
        self.isVerifiedPositive = false
        self.isBookmarked = false
        self.isRead = false
        self.readAt = nil
        self.cachedImageData = nil
        self.isCachedForOffline = false
    }
}

// MARK: - Convenience Extensions
extension Article {
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
    }

    var estimatedReadingTime: Int {
        let wordsPerMinute = 200
        let wordCount = (content ?? articleDescription ?? "").split(separator: " ").count
        return max(1, wordCount / wordsPerMinute)
    }
}
