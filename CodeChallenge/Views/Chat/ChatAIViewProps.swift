//
//  ChatAIViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation

protocol ChatAIViewProps {
    var store: Store { get }
    var mode: ChatMessagesMode { get }
}

enum ChatAIViewError {
    case unknownError
    case limitReached

    var description: String {
        switch self {
        case .unknownError:
            return "Oops 😵‍💫 ... Something happened on our side. Please come back later!"
        case .limitReached:
            return "You've reached your daily limit. Come back tomorrow to ask me more 😊 ! "
        }
    }
}

extension ChatAIViewProps {
    var chatMessages: [Resolvable<ChatMessage>] {
        return store.state.chatMessages[mode.identifier]?.filter { $0.value != nil } ?? []
    }

    var programmingLanguage: ProgrammingLanguage {
        return store.state.programmingLanguage
    }

    var assistantMessageIsLoading: Bool {
        store.state.chatMessages[mode.identifier]?.filter { $0.isLoading }.isEmpty == false
    }

    var assistantMessageError: ChatAIViewError? {
        guard let error = store.state.chatMessages[mode.identifier]?.compactMap({ $0.error }).first else { return nil }
        if let networkError = error as? NetworkError {
            switch networkError {
            case .api(let statusCode, _):
                return statusCode == 429 ? ChatAIViewError.limitReached : .unknownError
            default: return .unknownError
            }
        } else {
            return .unknownError
        }
    }

    func dismissView(on prompt: String) -> Bool {
        return prompt == mode.answerPrompts.first
    }
}
