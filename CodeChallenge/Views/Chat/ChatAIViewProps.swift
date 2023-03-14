//
//  ChatAIViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation

protocol ChatAIViewProps {
    var store: Store { get }
}

extension ChatAIViewProps {
    var chatMessages: [Resolvable<ChatMessage>] {
        return store.state.chatMessages.filter { $0.value != nil }
    }
}
