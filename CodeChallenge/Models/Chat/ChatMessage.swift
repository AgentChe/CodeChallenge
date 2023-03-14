//
//  ChatMessage.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation

struct ChatMessage: Codable {
    enum Role: String, Codable {
        case user
        case assistant
    }
    let role: Role
    let content: String
    let timestamp: Int?
}

struct AIResponse: Codable {
    struct Choice: Codable {
        let message: ChatMessage
    }
    let choices: [Choice]
    let created: Int
}
