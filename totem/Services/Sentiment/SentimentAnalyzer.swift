//
//  SentimentAnalyzer.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation
import NaturalLanguage

actor SentimentAnalyzer {
    static let shared = SentimentAnalyzer()

    private let tagger: NLTagger

    private init() {
        tagger = NLTagger(tagSchemes: [.sentimentScore])
    }

    /// Analyzes text and returns a sentiment score from -1.0 (negative) to 1.0 (positive)
    func analyze(text: String) -> Double {
        guard !text.isEmpty else { return 0 }

        tagger.string = text

        var totalScore: Double = 0
        var count: Int = 0

        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .paragraph,
            scheme: .sentimentScore,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, _ in
            if let tag = tag, let score = Double(tag.rawValue) {
                totalScore += score
                count += 1
            }
            return true
        }

        return count > 0 ? totalScore / Double(count) : 0
    }

    /// Quick check if text is positive (score >= 0)
    func isPositive(text: String) -> Bool {
        analyze(text: text) >= 0
    }

    /// Analyze multiple texts and return average sentiment
    func analyzeMultiple(texts: [String]) -> Double {
        guard !texts.isEmpty else { return 0 }

        let scores = texts.map { analyze(text: $0) }
        return scores.reduce(0, +) / Double(scores.count)
    }
}
