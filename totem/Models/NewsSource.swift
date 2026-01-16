//
//  NewsSource.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation

struct NewsSource: Identifiable, Codable {
    let id: String
    let name: String
    let feedURL: String
    let icon: String
    let defaultCategory: ArticleCategory
    let isEnabled: Bool

    init(
        name: String,
        feedURL: String,
        icon: String,
        defaultCategory: ArticleCategory,
        isEnabled: Bool = true
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.feedURL = feedURL
        self.icon = icon
        self.defaultCategory = defaultCategory
        self.isEnabled = isEnabled
    }
}

// MARK: - Default Sources
extension NewsSource {
    @MainActor static let defaultSources: [NewsSource] = [
        NewsSource(
            name: "Good News Network",
            feedURL: "https://www.goodnewsnetwork.org/feed/",
            icon: "sun.max.fill",
            defaultCategory: .goodNews
        ),
        NewsSource(
            name: "Positive News",
            feedURL: "https://www.positive.news/feed/",
            icon: "sparkles",
            defaultCategory: .inspiringStories
        ),
        NewsSource(
            name: "Reasons to be Cheerful",
            feedURL: "https://reasonstobecheerful.world/feed/",
            icon: "face.smiling.fill",
            defaultCategory: .goodNews
        ),
        NewsSource(
            name: "The Optimist Daily",
            feedURL: "https://www.theoptimistdaily.com/feed/",
            icon: "sunrise.fill",
            defaultCategory: .goodNews
        ),
        NewsSource(
            name: "Upworthy",
            feedURL: "https://www.upworthy.com/rss.xml",
            icon: "arrow.up.heart.fill",
            defaultCategory: .inspiringStories
        ),
        NewsSource(
            name: "Good Good Good",
            feedURL: "https://www.goodgoodgood.co/articles/rss.xml",
            icon: "hand.thumbsup.fill",
            defaultCategory: .actsOfKindness
        ),
        NewsSource(
            name: "Sunny Skyz",
            feedURL: "https://www.sunnyskyz.com/rss.xml",
            icon: "sun.max.fill",
            defaultCategory: .goodNews
        )
    ]
}
