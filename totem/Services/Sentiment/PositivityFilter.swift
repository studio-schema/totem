//
//  PositivityFilter.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation

actor PositivityFilter {
    static let shared = PositivityFilter()

    // Keywords that indicate negative content - block these
    private let blockedKeywords: Set<String> = [
        "death", "died", "killed", "murder", "tragedy", "disaster",
        "war", "attack", "violence", "shooting", "crash", "fatal",
        "scandal", "fraud", "corruption", "abuse", "crime", "criminal",
        "terrorist", "terrorism", "explosion", "bomb", "victim",
        "devastation", "catastrophe", "crisis", "emergency", "pandemic",
        "suicide", "overdose", "assault", "robbery", "theft"
    ]

    // Keywords that strongly indicate positive content
    private let positiveKeywords: Set<String> = [
        "success", "breakthrough", "discovery", "celebration",
        "achievement", "hero", "saved", "rescue", "innovation",
        "kindness", "charity", "volunteer", "hope", "inspiring",
        "uplifting", "heartwarming", "wholesome", "joy", "happiness",
        "recovery", "healing", "triumph", "overcome", "remarkable",
        "generous", "compassion", "miracle", "wonderful", "amazing"
    ]

    private let sentimentAnalyzer = SentimentAnalyzer.shared

    private init() {}

    /// Filter articles to only include verified positive content
    func filter(_ articles: [Article]) async -> [Article] {
        var filtered: [Article] = []

        for article in articles {
            if await isPositive(article) {
                var verifiedArticle = article
                verifiedArticle.isVerifiedPositive = true
                filtered.append(verifiedArticle)
            }
        }

        return filtered
    }

    /// Check if an article passes positivity requirements
    func isPositive(_ article: Article) async -> Bool {
        let text = "\(article.title) \(article.articleDescription ?? "")"
        let lowercasedText = text.lowercased()

        // Step 1: Check for blocked keywords
        for keyword in blockedKeywords {
            if lowercasedText.contains(keyword) {
                return false
            }
        }

        // Step 2: Check sentiment score
        // Already calculated during parsing, use it
        if article.sentimentScore < -0.3 {
            return false
        }

        // Step 3: Boost if contains positive keywords
        var positiveBoost = 0
        for keyword in positiveKeywords {
            if lowercasedText.contains(keyword) {
                positiveBoost += 1
            }
        }

        // If has positive keywords or neutral/positive sentiment, approve
        return positiveBoost > 0 || article.sentimentScore >= 0
    }

    /// Get positivity score for display (0-100)
    func getPositivityScore(_ article: Article) -> Int {
        // Convert -1 to 1 range to 0 to 100
        let normalizedScore = (article.sentimentScore + 1) / 2
        return Int(normalizedScore * 100)
    }
}
