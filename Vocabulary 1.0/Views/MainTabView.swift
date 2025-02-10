import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TranslatorView()
                .tabItem {
                    Label("Перекладач", systemImage: "text.bubble.fill")
                }
            
            FoldersView()
                .tabItem {
                    Label("Папки", systemImage: "folder.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Профіль", systemImage: "person.fill")
                }
        }
    }
} 