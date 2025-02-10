//
//  Vocabulary_1_0App.swift
//  Vocabulary 1.0
//
//  Created by The Weeknd on 10.02.2025.
//

import SwiftUI
import SwiftData

@main
struct Vocabulary_1_0App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Folder.self,
            Word.self,
            UserProfile.self
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
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// Основні моделі даних
@Model
final class Folder: Identifiable {
    let id: UUID
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var words: [Word]
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.words = []
    }
}

@Model
final class Word: Identifiable {
    let id: UUID
    var original: String
    var translation: String
    var isLearned: Bool
    var createdAt: Date
    var order: Int
    
    init(original: String, translation: String) {
        self.id = UUID()
        self.original = original
        self.translation = translation
        self.isLearned = false
        self.createdAt = Date()
        self.order = 0
    }
}

@Model
final class UserProfile {
    var playbackSpeed: Double
    var shuffleEnabled: Bool
    
    init() {
        self.playbackSpeed = 1.0
        self.shuffleEnabled = false
    }
}
