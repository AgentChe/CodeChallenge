//
//  ChatService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation
import Combine

protocol ChatServiceProtocol {
    func sendMessageToAI(_ content: String) -> AnyPublisher<ChatMessage, Error>
}

struct ChatService: ChatServiceProtocol {
    let networkService: NetworkServiceProtocol

    private let apiKey = "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"

    func sendMessageToAI(_ content: String) -> AnyPublisher<ChatMessage, Error> {
        let params: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": content]]
          ]
        let headers = ["Content-Type": "application/json", "Authorization": "Bearer \(apiKey)"]
        return URLRequest
            .create(url: "https://api.openai.com/v1/chat/completions", type: .post, params: params, headers: headers)
            .flatMap { networkService.load($0, decoding: AIResponse.self, with: .snakeCase) }
            .compactMap { $0.choices.randomElement()?.message }
            .eraseToAnyPublisher()
    }
}
