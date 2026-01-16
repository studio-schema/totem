//
//  Date+Extensions.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation

extension Date {
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var fullFormatted: String {
        formatted(date: .abbreviated, time: .shortened)
    }
}
