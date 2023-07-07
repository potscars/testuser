//
//  Extension+Notification.swift
//  TestUser
//
//  Created by owner on 07/07/2023.
//

import Foundation

extension Notification.Name {
    static let connectivityStatus = Notification.Name(rawValue: "connectivityStatusChanged")
    static let savedNotes = Notification.Name("savedNotes")
}
