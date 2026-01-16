//
//  totemApp.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI
import SwiftData

@main
struct TotemApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Article.self,
            Bookmark.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
