struct Folder: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var words: [Word]
    var parentFolderId: UUID?
    var createdAt: Date
    var updatedAt: Date
    
    mutating func addWord(_ word: Word) {
        words.append(word)
        updatedAt = Date()
    }
    
    mutating func removeWord(_ word: Word) {
        words.removeAll { $0.id == word.id }
        updatedAt = Date()
    }
    
    mutating func updateName(_ newName: String) {
        name = newName
        updatedAt = Date()
    }
} 