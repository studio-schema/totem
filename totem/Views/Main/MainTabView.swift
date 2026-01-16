//
//  MainTabView.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var feedViewModel = FeedViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView(viewModel: feedViewModel)
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(0)

            BookmarksView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(1)

            SearchView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.primary)
        .onAppear {
            feedViewModel.configure(with: modelContext)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Article.self, inMemory: true)
}
