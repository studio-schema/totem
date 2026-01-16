//
//  Category.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation
import SwiftUI

enum ArticleCategory: String, Codable, CaseIterable, Identifiable {
    case forYou = "for_you"
    case goodNews = "good_news"
    case inspiringStories = "inspiring_stories"
    case actsOfKindness = "acts_of_kindness"
    case scienceInnovation = "science_innovation"
    case environment = "environment"
    case healthWellness = "health_wellness"
    case artsCulture = "arts_culture"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .forYou: return "For You"
        case .goodNews: return "Good News"
        case .inspiringStories: return "Inspiring Stories"
        case .actsOfKindness: return "Acts of Kindness"
        case .scienceInnovation: return "Science & Innovation"
        case .environment: return "Environment"
        case .healthWellness: return "Health & Wellness"
        case .artsCulture: return "Arts & Culture"
        }
    }

    var icon: String {
        switch self {
        case .forYou: return "sparkles"
        case .goodNews: return "sun.max.fill"
        case .inspiringStories: return "star.fill"
        case .actsOfKindness: return "heart.fill"
        case .scienceInnovation: return "atom"
        case .environment: return "leaf.fill"
        case .healthWellness: return "figure.walk"
        case .artsCulture: return "paintpalette.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .forYou: return [Color.indigo, Color.purple]
        case .goodNews: return [Color.yellow, Color.orange]
        case .inspiringStories: return [Color.purple, Color.pink]
        case .actsOfKindness: return [Color.pink, Color.red]
        case .scienceInnovation: return [Color.blue, Color.cyan]
        case .environment: return [Color.green, Color.teal]
        case .healthWellness: return [Color.mint, Color.green]
        case .artsCulture: return [Color.orange, Color.pink]
        }
    }

    var primaryColor: Color {
        gradient.first ?? .blue
    }

    var keywords: [String] {
        switch self {
        case .forYou:
            return []
        case .goodNews:
            return ["positive", "uplifting", "success", "breakthrough", "achievement", "celebrate", "joy", "happy"]
        case .inspiringStories:
            return ["inspiration", "hero", "overcome", "triumph", "courage", "brave", "remarkable", "extraordinary"]
        case .actsOfKindness:
            return ["kindness", "charity", "volunteer", "donate", "help", "community", "generous", "compassion"]
        case .scienceInnovation:
            return ["discovery", "innovation", "research", "breakthrough", "cure", "solution", "technology", "science"]
        case .environment:
            return ["sustainability", "conservation", "clean", "renewable", "wildlife", "nature", "climate", "green"]
        case .healthWellness:
            return ["wellness", "recovery", "fitness", "mental health", "healing", "healthy", "self-care", "wellbeing"]
        case .artsCulture:
            return ["creativity", "music", "art", "culture", "exhibition", "performance", "artist", "creative"]
        }
    }
}
