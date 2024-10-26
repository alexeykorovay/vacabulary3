//
//  Item.swift
//  VocabularyApp3.0
//
//  Created by The Weeknd on 25.10.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
