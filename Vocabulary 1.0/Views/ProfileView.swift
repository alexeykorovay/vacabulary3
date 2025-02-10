import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var folders: [Folder]
    
    var userProfile: UserProfile {
        if let profile = userProfiles.first {
            return profile
        } else {
            let profile = UserProfile()
            modelContext.insert(profile)
            return profile
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Налаштування відтворення") {
                    HStack {
                        Text("Швидкість: \(String(format: "%.1f", userProfile.playbackSpeed))x")
                        Slider(value: .init(
                            get: { userProfile.playbackSpeed },
                            set: { userProfile.playbackSpeed = $0 }
                        ), in: 0.5...2.0, step: 0.1)
                    }
                    
                    Toggle("Перемішувати слова", isOn: .init(
                        get: { userProfile.shuffleEnabled },
                        set: { userProfile.shuffleEnabled = $0 }
                    ))
                }
                
                Section("Статистика") {
                    HStack {
                        Text("Всього слів")
                        Spacer()
                        Text("\(getTotalWordsCount())")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Вивчено слів")
                        Spacer()
                        Text("\(getLearnedWordsCount())")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Профіль")
        }
    }
    
    private func getTotalWordsCount() -> Int {
        folders.flatMap { $0.words }.count
    }
    
    private func getLearnedWordsCount() -> Int {
        folders.flatMap { $0.words }.filter { $0.isLearned }.count
    }
} 