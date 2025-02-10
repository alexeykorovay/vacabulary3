import SwiftUI
import SwiftData

struct FoldersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [Folder]
    
    @State private var selectedFolderIds: Set<UUID> = []
    @State private var showingAddFolder = false
    @State private var newFolderName = ""
    @State private var showingPlayer = false
    
    var selectedFolders: [Folder] {
        folders.filter { selectedFolderIds.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(folders) { folder in
                    NavigationLink {
                        FolderDetailView(folder: folder)
                    } label: {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(folder.name)
                                    .font(.headline)
                                Text("\(folder.words.count) слів")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Папки")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddFolder = true }) {
                        Label("Додати папку", systemImage: "folder.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFolder) {
                NavigationStack {
                    Form {
                        TextField("Назва папки", text: $newFolderName)
                    }
                    .navigationTitle("Нова папка")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Скасувати") {
                                showingAddFolder = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Додати") {
                                addFolder()
                            }
                            .disabled(newFolderName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(150)])
            }
        }
    }
    
    private func addFolder() {
        let folder = Folder(name: newFolderName)
        modelContext.insert(folder)
        newFolderName = ""
        showingAddFolder = false
    }
}

struct FolderRow: View {
    let folder: Folder
    
    var body: some View {
        NavigationLink(destination: FolderDetailView(folder: folder)) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text(folder.name)
                        .font(.headline)
                    Text("\(folder.words.count) слів")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
} 