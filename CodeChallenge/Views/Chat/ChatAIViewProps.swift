//
//  ChatAIViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation

protocol ChatAIViewProps {
    var store: Store { get }
    var challengeDetail: ChallengeDetail { get }
    var mode: ChatMessagesMode { get }
}

extension ChatAIViewProps {
    var identifier: String {
        "\(mode.rawValue)_\(challengeDetail.id)"
    }
    var chatMessages: [Resolvable<ChatMessage>] {
        return store.state.chatMessages[identifier]?.filter { $0.value != nil } ?? []
    }

    var prompts: [String] {
        return ["Yes, I’m all set", "Can I see an example?", "No, please elaborate"]
    }

    var programmingLanguage: ProgrammingLanguage {
        return store.state.programmingLanguage
    }

    var latestCompiledCode: String? {
        store.state.challengeProgresses[challengeDetail.id]?.value?.solution?.python.removingPercentEncoding ?? ""
    }

    var startMessage: String {
        let challengeDescription = challengeDetail.body.toAttributedString().string
        switch mode {
        case .provideSolution:
            return "Can you solve the following problem using \(programmingLanguage.rawValue)? \(challengeDescription)"
        case .explain:
            return """
This is the problem I am trying to solve in \(programmingLanguage.rawValue): \n\(challengeDescription).\nCan you explain what's wrong in my solution:\n```\(latestCompiledCode ?? "")```\n
"""
        }
    }

    func dismissView(on prompt: String) -> Bool {
        return prompt == prompts.first
    }
}
