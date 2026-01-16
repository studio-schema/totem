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

    // MARK: - Layer 1: Blocked Keywords

    private let blockedKeywords: Set<String> = [
        // Violence & Crime
        "murder", "murdered", "killed", "killing", "shooting", "shot", "stabbed",
        "assault", "assaulted", "attack", "attacked", "violence", "violent",
        "crime", "criminal", "robbery", "theft", "arrested", "prison", "jail",
        "sentenced", "gunman", "shooter", "homicide", "manslaughter",

        // Disaster & Tragedy
        "disaster", "catastrophe", "tragedy", "tragic", "devastation", "devastated",
        "destroyed", "destruction", "collapse", "collapsed", "crash", "crashed",
        "explosion", "exploded", "flood", "flooding", "earthquake", "hurricane",
        "tornado", "wildfire", "inferno", "blaze", "burns", "burned",

        // Death & Harm
        "death", "deaths", "died", "dead", "deadly", "fatal", "fatality",
        "victim", "victims", "casualties", "injured", "injuries", "wounded",
        "hurt", "killed", "perished", "mourning", "grief",

        // Conflict & Politics
        "war", "warfare", "military", "troops", "bombing", "bombed", "missile",
        "missiles", "conflict", "battle", "protest", "protests", "riot", "riots",
        "strike", "political", "politician", "election", "scandal", "corruption",
        "fraud", "lawsuit", "sued", "indicted", "impeach", "partisan",

        // Health Crises
        "pandemic", "epidemic", "outbreak", "infection", "infected", "disease",
        "cancer", "tumor", "hospitalized", "emergency", "overdose", "suicide",
        "addiction", "addicted", "diagnosis", "diagnosed",

        // Economic Negativity
        "recession", "layoffs", "laid off", "unemployment", "unemployed",
        "bankrupt", "bankruptcy", "foreclosure", "debt", "crash", "plunge",
        "plummet", "collapse", "downturn", "cuts", "deficit", "inflation",

        // Negative Emotions
        "fear", "fears", "feared", "worried", "worry", "worrying", "concern",
        "concerns", "alarming", "alarmed", "threat", "threatens", "threatening",
        "warning", "warns", "danger", "dangerous", "risk", "risks", "risky",
        "scary", "terrifying", "terrified", "horrific", "horrible", "awful",
        "terrible", "devastating", "shocking", "outrage", "outraged", "anger",
        "angry", "furious", "disturbing", "disturbed",

        // Celebrity & Tabloid Content
        "celebrity", "celebrities", "famous", "star", "starlet", "hollywood",
        "kardashian", "kanye", "taylor swift", "beyonce", "drake", "bieber",
        "reality tv", "reality show", "bachelor", "bachelorette", "housewives",
        "red carpet", "paparazzi", "tabloid", "gossip", "rumor", "rumors",
        "dating", "boyfriend", "girlfriend", "engaged", "engagement", "wedding",
        "married", "marriage", "divorce", "divorced", "split", "breakup",
        "cheating", "affair", "ex-wife", "ex-husband", "custody",
        "feud", "drama", "claps back", "slams", "blasts", "shades",
        "opens up about", "gets candid", "reveals", "confesses", "admits",
        "roller coaster", "rocky", "struggles", "struggled", "fighting",

        // Entertainment Fluff
        "episode", "season", "finale", "premiere", "ratings", "renewed",
        "canceled", "cancelled", "reboot", "spinoff", "sequel", "prequel",
        "box office", "streaming", "netflix", "hulu", "disney+",
        "instagram", "tiktok", "viral video", "went viral", "trending",
        "selfie", "photoshoot", "makeover", "transformation",
        "weight loss", "diet", "plastic surgery", "cosmetic"
    ]

    // MARK: - Layer 3: Required Positive Signals (substantive positive news)

    private let positiveSignals: Set<String> = [
        // Scientific & Medical Progress
        "breakthrough", "discovery", "discovered", "researchers", "scientists",
        "study finds", "cure", "treatment", "vaccine", "clinical trial",
        "innovation", "innovative", "technology", "renewable", "sustainable",

        // Community & Social Good
        "volunteer", "volunteered", "volunteering", "donate", "donated",
        "donation", "charity", "charitable", "nonprofit", "fundraiser",
        "community", "neighbors", "local hero", "rescue", "rescued",
        "saved", "saving lives", "food bank", "shelter",

        // Environmental Progress
        "conservation", "protected", "restored", "reforestation", "clean energy",
        "solar", "wind power", "electric", "emissions", "recycling",
        "endangered species", "wildlife", "habitat", "ocean cleanup",

        // Education & Opportunity
        "scholarship", "graduated", "education", "students", "school",
        "literacy", "mentorship", "training", "skills", "opportunity",

        // Human Achievement
        "milestone", "record-breaking", "first ever", "youngest", "oldest",
        "overcame", "perseverance", "dedication", "determination",

        // Genuine Kindness
        "kindness", "generous", "generosity", "compassion", "compassionate",
        "selfless", "heartwarming", "uplifting", "inspiring", "hero",
        "helped", "helping hand", "paid it forward", "random act"
    ]

    // MARK: - Strong Signals (bonus points for substantive content)

    private let strongSignals: Set<String> = [
        "breakthrough", "scientists", "researchers", "discovery", "cure",
        "volunteer", "donated", "rescued", "conservation", "renewable",
        "scholarship", "community", "hero", "milestone", "first ever"
    ]

    private init() {}

    // MARK: - Public Methods

    /// Filter articles using 4-layer positivity system
    func filter(_ articles: [Article]) -> [Article] {
        var filtered: [Article] = []

        for article in articles {
            let (passes, score) = evaluate(article)
            if passes {
                article.isVerifiedPositive = true
                article.sentimentScore = Double(score) / 100.0  // Store normalized score
                filtered.append(article)
            }
        }

        return filtered
    }

    /// Evaluate article through all 4 layers
    func evaluate(_ article: Article) -> (passes: Bool, score: Int) {
        let text = buildSearchText(from: article)
        let lowercased = text.lowercased()

        // Layer 1: Block negative topics
        if containsBlockedKeyword(lowercased) {
            return (false, 0)
        }

        // Layer 2: Require positive sentiment (>= 0.3)
        if article.sentimentScore < 0.3 {
            return (false, 0)
        }

        // Layer 3: Require at least one positive signal
        if !containsPositiveSignal(lowercased) {
            return (false, 0)
        }

        // Layer 4: Calculate score (must be >= 65)
        let score = calculateScore(article, text: lowercased)
        return (score >= 65, score)
    }

    /// Get positivity score for display (0-100)
    func getPositivityScore(_ article: Article) -> Int {
        let (_, score) = evaluate(article)
        return score
    }

    // MARK: - Private Methods

    private func buildSearchText(from article: Article) -> String {
        var components = [article.title]

        if let description = article.articleDescription {
            components.append(description)
        }

        if let content = article.content {
            components.append(content)
        }

        return components.joined(separator: " ")
    }

    private func containsBlockedKeyword(_ text: String) -> Bool {
        for keyword in blockedKeywords {
            // Use word boundary matching to avoid false positives
            // e.g., "therapist" shouldn't match "the rapist"
            if text.contains(keyword) {
                // Check it's a word boundary
                let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(text.startIndex..., in: text)
                    if regex.firstMatch(in: text, options: [], range: range) != nil {
                        return true
                    }
                }
            }
        }
        return false
    }

    private func containsPositiveSignal(_ text: String) -> Bool {
        for signal in positiveSignals {
            if text.contains(signal) {
                return true
            }
        }
        return false
    }

    private func calculateScore(_ article: Article, text: String) -> Int {
        var score = 0

        // Sentiment contribution (0-40 points)
        // Sentiment ranges from -1 to 1, normalize to 0-40
        let normalizedSentiment = (article.sentimentScore + 1) / 2  // 0 to 1
        let sentimentPoints = Int(normalizedSentiment * 40)
        score += sentimentPoints

        // Positive keywords contribution (+5 each, max 30 points)
        var keywordPoints = 0
        for signal in positiveSignals {
            if text.contains(signal) {
                keywordPoints += 5
                if keywordPoints >= 30 { break }
            }
        }
        score += keywordPoints

        // Clean content bonus (+20 points if no blocked keywords)
        if !containsBlockedKeyword(text) {
            score += 20
        }

        // Strong signal bonus (+10 points)
        for signal in strongSignals {
            if text.contains(signal) {
                score += 10
                break  // Only count once
            }
        }

        return score
    }
}
