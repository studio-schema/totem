//
//  NewsSource.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation

struct NewsSource: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let feedURL: String
    let icon: String
    let defaultCategoryRaw: String
    let isEnabled: Bool

    var defaultCategory: ArticleCategory {
        ArticleCategory(rawValue: defaultCategoryRaw) ?? .goodNews
    }

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
        self.defaultCategoryRaw = defaultCategory.rawValue
        self.isEnabled = isEnabled
    }
}

// MARK: - Default Sources (20+ sources for comprehensive coverage)
extension NewsSource {
    static let defaultSources: [NewsSource] = [
        // MARK: - Good News / General Positive
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
            defaultCategory: .goodNews
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
            name: "Sunny Skyz",
            feedURL: "https://www.sunnyskyz.com/rss.xml",
            icon: "sun.max.fill",
            defaultCategory: .goodNews
        ),
        NewsSource(
            name: "Daily Good",
            feedURL: "https://www.dailygood.org/rss.xml",
            icon: "heart.circle.fill",
            defaultCategory: .goodNews
        ),

        // MARK: - Inspiring Stories
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
            defaultCategory: .inspiringStories
        ),
        NewsSource(
            name: "Inspire More",
            feedURL: "https://www.inspiremore.com/feed/",
            icon: "star.fill",
            defaultCategory: .inspiringStories
        ),

        // MARK: - Science & Innovation
        NewsSource(
            name: "Science Daily - Health",
            feedURL: "https://www.sciencedaily.com/rss/health_medicine.xml",
            icon: "cross.case.fill",
            defaultCategory: .scienceInnovation
        ),
        NewsSource(
            name: "Science Daily - Tech",
            feedURL: "https://www.sciencedaily.com/rss/computers_math.xml",
            icon: "cpu.fill",
            defaultCategory: .scienceInnovation
        ),
        NewsSource(
            name: "Phys.org - Technology",
            feedURL: "https://phys.org/rss-feed/technology-news/",
            icon: "lightbulb.fill",
            defaultCategory: .scienceInnovation
        ),
        NewsSource(
            name: "MIT News",
            feedURL: "https://news.mit.edu/rss/feed",
            icon: "graduationcap.fill",
            defaultCategory: .scienceInnovation
        ),

        // MARK: - Environment
        NewsSource(
            name: "Treehugger",
            feedURL: "https://www.treehugger.com/feeds/all",
            icon: "leaf.fill",
            defaultCategory: .environment
        ),
        NewsSource(
            name: "EcoWatch",
            feedURL: "https://www.ecowatch.com/rss",
            icon: "globe.americas.fill",
            defaultCategory: .environment
        ),
        NewsSource(
            name: "The Guardian - Environment",
            feedURL: "https://www.theguardian.com/environment/rss",
            icon: "tree.fill",
            defaultCategory: .environment
        ),

        // MARK: - Health & Wellness
        NewsSource(
            name: "Mindful",
            feedURL: "https://www.mindful.org/feed/",
            icon: "brain.head.profile",
            defaultCategory: .healthWellness
        ),
        NewsSource(
            name: "Well+Good",
            feedURL: "https://www.wellandgood.com/feed/",
            icon: "figure.mind.and.body",
            defaultCategory: .healthWellness
        ),
        NewsSource(
            name: "Tiny Buddha",
            feedURL: "https://tinybuddha.com/feed/",
            icon: "sparkle",
            defaultCategory: .healthWellness
        ),

        // MARK: - Acts of Kindness
        NewsSource(
            name: "Random Acts of Kindness",
            feedURL: "https://www.randomactsofkindness.org/feed",
            icon: "heart.fill",
            defaultCategory: .actsOfKindness
        ),

        // MARK: - Arts & Culture
        NewsSource(
            name: "Colossal",
            feedURL: "https://www.thisiscolossal.com/feed/",
            icon: "paintpalette.fill",
            defaultCategory: .artsCulture
        ),
        NewsSource(
            name: "Brain Pickings",
            feedURL: "https://www.themarginalian.org/feed/",
            icon: "book.fill",
            defaultCategory: .artsCulture
        ),
        NewsSource(
            name: "Open Culture",
            feedURL: "https://www.openculture.com/feed",
            icon: "music.note",
            defaultCategory: .artsCulture
        )
    ]
}
