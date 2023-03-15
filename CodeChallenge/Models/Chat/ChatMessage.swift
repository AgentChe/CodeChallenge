//
//  ChatMessage.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation

enum ChatMessagesMode: String {
    case explain
    case provideSolution
}

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

extension Array where Element == ChatMessage {
    var keyValuePairs: [[String: String]] {
        return self.map { ["role": $0.role.rawValue, "content": $0.content] }
    }
}
