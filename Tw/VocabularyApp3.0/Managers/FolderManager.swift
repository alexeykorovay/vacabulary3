class FolderManager: ObservableObject {
    @Published var folders: [Folder] = []
    
    func createFolder(name: String) -> Folder {
        let newFolder = Folder(
            name: name,
            words: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        folders.append(newFolder)
        return newFolder
    }
    
    func deleteFolder(_ folder: Folder) {
        folders.removeAll { $0.id == folder.id }
    }
    
    func mergeFolders(_ folders: [Folder], newName: String) -> Folder {
        let allWords = folders.flatMap { $0.words }
        let mergedFolder = Folder(
            name: newName,
            words: allWords,
            createdAt: Date(),
            updatedAt: Date()
        )
        self.folders.append(mergedFolder)
        return mergedFolder
    }
    
    func addWord(to folder: Folder, word: Word) {
        guard let index = folders.firstIndex(where: { $0.id == folder.id }) else { return }
        folders[index].addWord(word)
    }
} 