//
//  ChatService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation
import Combine

protocol ChatServiceProtocol {
    func sendMessageToAI(_ content: String, history: [ChatMessage]) -> AnyPublisher<ChatMessage, Error>
}

struct ChatService: ChatServiceProtocol {
    let networkService: NetworkServiceProtocol

    func sendMessageToAI(_ content: String, history: [ChatMessage]) -> AnyPublisher<ChatMessage, Error> {
        var array = [["role": "system", "content": "You are a helpful assistant."]]
        array.insert(contentsOf: history.keyValuePairs, at: 1)
        array.append(["role": "user", "content": content])
        let params: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": array,
            "temperature": 1.0
          ]
        return URLRequest
            .create(url: "\(Configuration.host)/messages/send_message/", type: .post, params: params)
            .flatMap { networkService.load($0, decoding: AIResponse.self, with: .snakeCase) }
            .compactMap { $0.choices.randomElement()?.message }
            .eraseToAnyPublisher()
    }
}
