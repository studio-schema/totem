//
//  PositivityFilter.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation

@MainActor
final class PositivityFilter {
    static let shared = PositivityFilter()

    // Keywords that indicate strongly negative content - block these
    private let blockedKeywords: Set<String> = [
        "murder", "killed", "shooting", "terrorist", "terrorism",
        "massacre", "slaughter", "execution", "homicide"
    ]

    // Keywords that strongly indicate positive content - auto-approve
    private let positiveKeywords: Set<String> = [
        "success", "breakthrough", "discovery", "celebration",
        "achievement", "hero", "saved", "rescue", "innovation",
        "kindness", "charity", "volunteer", "hope", "inspiring",
        "uplifting", "heartwarming", "wholesome", "joy", "happiness",
        "recovery", "healing", "triumph", "overcome", "remarkable",
        "generous", "compassion", "miracle", "wonderful", "amazing",
        "sustainable", "renewable", "conservation", "wellness",
        "mindful", "creative", "artistic", "community", "together"
    ]

    private init() {}

    /// Filter articles - more permissive since sources are curated positive news sites
    func filter(_ articles: [Article]) -> [Article] {
        var filtered: [Article] = []

        for article in articles {
            if isPositive(article) {
                article.isVerifiedPositive = true
                filtered.append(article)
            }
        }

        return filtered
    }

    /// Check if an article passes positivity requirements
    /// Since we're sourcing from positive news sites, we're more lenient
    func isPositive(_ article: Article) -> Bool {
        let text = "\(article.title) \(article.articleDescription ?? "")"
        let lowercasedText = text.lowercased()

        // Step 1: Block only strongly negative content
        for keyword in blockedKeywords {
            if lowercasedText.contains(keyword) {
                return false
            }
        }

        // Step 2: Auto-approve if contains positive keywords
        for keyword in positiveKeywords {
            if lowercasedText.contains(keyword) {
                return true
            }
        }

        // Step 3: Allow if sentiment is not strongly negative
        // Since sources are curated, be more permissive
        return article.sentimentScore >= -0.5
    }

    /// Get positivity score for display (0-100)
    func getPositivityScore(_ article: Article) -> Int {
        let normalizedScore = (article.sentimentScore + 1) / 2
        return Int(normalizedScore * 100)
    }
}
