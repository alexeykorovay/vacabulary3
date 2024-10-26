//
//  VocabularyApp3_0App.swift
//  VocabularyApp3.0
//
//  Created by The Weeknd on 25.10.2024.
//

import SwiftUI
import SwiftData

@main
struct VocabularyApp3_0App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            FolderView()
        }
        .modelContainer(sharedModelContainer)
    }
}
