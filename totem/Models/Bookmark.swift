//
//  Bookmark.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation
import SwiftData

@Model
final class Bookmark {
    @Attribute(.unique) var id: UUID
    var articleID: String
    var createdAt: Date
    var note: String?

    init(articleID: String, note: String? = nil) {
        self.id = UUID()
        self.articleID = articleID
        self.createdAt = Date()
        self.note = note
    }
}
