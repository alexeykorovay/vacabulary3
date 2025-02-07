struct Word: Codable, Identifiable {
    var id: UUID = UUID()
    var original: String
    var translation: String
    var isLearned: Bool = false
    var createdAt: Date
    var order: Int
    
    mutating func markAsLearned() {
        isLearned = true
    }
    
    mutating func updateOrder(_ newOrder: Int) {
        order = newOrder
    }
} 