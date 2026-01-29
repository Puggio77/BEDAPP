//
//  ChatMessage.swift
//  BEDAPP
//
//  Created by Riccardo Puggioni on 27/01/26.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let date: Date = Date()
}
