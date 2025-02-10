//
//  Item.swift
//  Vocabulary 1.0
//
//  Created by The Weeknd on 10.02.2025.
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
