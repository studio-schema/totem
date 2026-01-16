# Totem - Positive News iOS App

> Apple News clone for uplifting, positive, inspiring content only

**Status:** In Development - Phase 2 Complete
**Target:** iOS 26
**Last Updated:** 2026-01-16
**GitHub:** https://github.com/studio-schema/totem

---

## Overview

Totem is a premium iOS news app that curates and displays only positive, uplifting news. Uses RSS feed aggregation from curated positive news sources combined with on-device AI sentiment filtering for quality assurance.

---

## Architecture Summary

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│  SwiftUI Views + iOS 18 Features (Zoom, MeshGradient)       │
├─────────────────────────────────────────────────────────────┤
│                    ViewModel Layer                           │
│  @Observable ViewModels + State Management                   │
├─────────────────────────────────────────────────────────────┤
│                    Service Layer                             │
│  RSS Parsing │ Sentiment Analysis │ Background Tasks         │
├─────────────────────────────────────────────────────────────┤
│                     Data Layer                               │
│  SwiftData Models + Offline Cache                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Technical Decisions

### News Source Strategy (RSS Feeds - FREE)
**Primary Sources:**
- Good News Network (goodnewsnetwork.org/feed)
- Positive News (positive.news/feed)
- Reasons to be Cheerful (reasonstobecheerful.world/feed)
- The Optimist Daily (theoptimistdaily.com/feed)
- Upworthy (upworthy.com/feed)
- Good Good Good (goodgoodgood.co/feed)
- Sunny Skyz (sunnyskyz.com/rss)

**On-Device Verification:**
- Apple NaturalLanguage framework for sentiment scoring
- Keyword filtering for any negative content that slips through

### Design Patterns
- SwiftUI with @Observable macro (iOS 17+)
- NavigationStack with type-safe routing
- iOS 18 zoom transitions between cards and detail
- MeshGradient for dynamic backgrounds
- LazyVStack for performance

### Persistence
- SwiftData for articles, bookmarks, reading history
- URLCache for image caching
- App Groups for widget data sharing

---

## File Structure

```
totem/
├── totemApp.swift
├── ContentView.swift
├── Models/
│   ├── Article.swift              # SwiftData model
│   ├── Category.swift             # Enum with icons/colors
│   ├── Bookmark.swift
│   └── NewsSource.swift           # RSS source model
├── Services/
│   ├── RSS/
│   │   ├── RSSParser.swift        # XMLParser for feeds
│   │   └── FeedAggregator.swift   # Combines all sources
│   └── Sentiment/
│       ├── SentimentAnalyzer.swift
│       └── PositivityFilter.swift
├── ViewModels/
│   └── FeedViewModel.swift
├── Views/
│   ├── Main/
│   │   ├── MainTabView.swift
│   │   └── SettingsView.swift
│   ├── Feed/
│   │   ├── FeedView.swift
│   │   └── CategoryFilterBar.swift
│   ├── Article/
│   │   └── ArticleDetailView.swift
│   ├── Cards/
│   │   ├── HeroArticleCard.swift
│   │   └── StandardArticleCard.swift
│   ├── Bookmarks/
│   │   └── BookmarksView.swift
│   └── Search/
│       └── SearchView.swift
└── Extensions/
    └── Date+Extensions.swift
```

---

## Categories (8 Total)

| Category | Icon | Colors | Keywords |
|----------|------|--------|----------|
| For You | sparkles | indigo → purple | Personalized mix |
| Good News | sun.max.fill | yellow → orange | positive, uplifting, success |
| Inspiring Stories | star.fill | purple → pink | inspiration, hero, triumph |
| Acts of Kindness | heart.fill | pink → red | kindness, charity, volunteer |
| Science & Innovation | atom | blue → cyan | discovery, breakthrough, cure |
| Environment | leaf.fill | green → teal | sustainability, conservation, clean |
| Health & Wellness | figure.walk | mint → green | wellness, recovery, fitness |
| Arts & Culture | paintpalette.fill | orange → pink | creativity, music, art |

---

## Implementation Phases

### Phase 1: Foundation ✅ COMPLETE
- [x] Initialize git repository
- [x] Set up SwiftData models (Article, Bookmark, NewsSource)
- [x] Implement RSSParser with XMLParser
- [x] Create FeedAggregator for multiple sources
- [x] Build SentimentAnalyzer with NaturalLanguage
- [x] Implement PositivityFilter

### Phase 2: Core UI ✅ COMPLETE
- [x] Create MainTabView with 4 tabs
- [x] Build FeedViewModel with @Observable
- [x] Implement FeedView with LazyVStack
- [x] Create HeroArticleCard with MeshGradient
- [x] Build StandardArticleCard
- [x] Implement CategoryFilterBar (horizontal scroll)
- [x] Add pull-to-refresh

### Phase 3: Detail & Navigation ✅ COMPLETE
- [x] Build ArticleDetailView with parallax
- [x] Implement iOS 18 zoom transitions
- [x] Create share functionality
- [ ] Add WebView for full article reading
- [ ] Add reading progress tracking

### Phase 4: Features - IN PROGRESS
- [x] Implement BookmarksView
- [ ] Add offline article caching
- [x] Create SearchView with filtering
- [x] Build Settings view
- [ ] Add source management

### Phase 5: Polish - PENDING
- [ ] Add Widget extension
- [ ] Implement background refresh
- [ ] Add accessibility (VoiceOver, Dynamic Type)
- [ ] Polish animations and haptics
- [ ] Performance optimization

---

## Sentiment Filtering Pipeline

```
1. Fetch RSS Feeds (7 sources)
   └── Parse XML with XMLParser
   └── Extract: title, description, link, pubDate, image

2. Category Assignment
   └── Match keywords to categories
   └── Use source default as fallback

3. Keyword Pre-Filter
   └── Block: death, war, violence, crime, tragedy
   └── Boost: success, hero, kindness, hope, joy

4. On-Device Sentiment (NaturalLanguage)
   └── Analyze title + description
   └── Score: -1.0 to +1.0
   └── Require: >= 0.0 (neutral or positive)

5. Persist to SwiftData
   └── Deduplicate by URL
   └── Cache for offline reading
```

---

## Apple Design Award Criteria

### Innovation
- RSS aggregation from curated positive sources
- On-device ML sentiment verification
- Smart category assignment

### Visual Design
- MeshGradient animated backgrounds
- iOS 18 zoom transitions
- Glass morphism materials
- Parallax scrolling on images

### Accessibility
- VoiceOver with semantic labels
- Dynamic Type (up to AX5)
- Reduce Motion support
- High contrast compatibility

### Performance
- LazyVStack for efficient scrolling
- Image caching with URLCache
- Background refresh every 15 min
- Skeleton loading states

---

## Verification Plan

1. **Build Verification**
   - Run `xcodebuild -scheme totem -destination 'platform=iOS Simulator,id=23094D81-00C9-4D8A-A695-E3A7D49BCABD'`
   - Fix any compile errors
   - Verify previews render

2. **RSS Testing**
   - Test each feed URL for accessibility
   - Verify XML parsing works
   - Check image extraction

3. **UI Testing**
   - Verify zoom transitions
   - Test pull-to-refresh
   - Check category filtering
   - Test dark mode

4. **Performance**
   - Profile scrolling with Instruments
   - Check memory usage
   - Verify image caching

---

## Git Workflow

```bash
# After each feature/fix:
git add .
git commit -m "feat: [description]"
git push origin main
```

---

## Changelog

### 2026-01-16 (Build 3)
- ✅ BUILD SUCCEEDED - RSS FEEDS WORKING
- Fixed RSSParser race condition (changed from actor to class)
- Updated FeedAggregator for Swift 6 concurrency compliance
- RSS feeds now fetch and display real articles from:
  - Good Good Good
  - Reasons to be Cheerful
  - Good News Network
  - Positive News
  - The Optimist Daily
  - Upworthy
  - Sunny Skyz
- Sentiment analysis and category detection working
- Removed sample data fallback, app shows loading state while fetching

### 2026-01-16 (Build 2)
- ✅ BUILD SUCCEEDED
- Implemented full core app structure
- Created SwiftData models (Article, Category, Bookmark, NewsSource)
- Built RSS parser and feed aggregator
- Added sentiment analysis with NaturalLanguage
- Created positivity filter with keyword blocking
- Built FeedViewModel with @Observable
- Implemented MainTabView with 4 tabs
- Created FeedView with LazyVStack and pull-to-refresh
- Built HeroArticleCard with MeshGradient
- Created StandardArticleCard
- Added ArticleDetailView with parallax and zoom transitions
- Implemented BookmarksView, SearchView, SettingsView
- Pushed to GitHub: https://github.com/studio-schema/totem

### 2026-01-16 (Build 1)
- Initial plan created
- Chose RSS feed approach (free)
- Expanded to 8 categories
- Defined 7 positive news sources
- Architecture designed
- Implementation phases outlined
