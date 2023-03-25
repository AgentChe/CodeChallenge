//
//  ChatMessage.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation

enum ChatMessagesMode {
    case explain(String, ChallengeDetail)
    case provideSolution(ChallengeDetail)
    case explainTopic(ChallengeCollectionContent, ProgrammingLanguage)
}

extension ChatMessagesMode {
    var identifier: String {
        switch self {
            case .provideSolution(let challenge):
            return "provideSolution_\(challenge.id)"
        case .explain(_, let challenge):
            return "explain_\(challenge.id)"
            case .explainTopic(let content, _):
            return "explainTopic_\(content.id)"
        }
    }
    var startMessage: String {
        switch self {
            case .provideSolution(let challenge):
            let challengeDescription = challenge.body.toAttributedString().string
                return "Can you solve the following problem using \(challenge.codehubProgrammingLanguage.rawValue)? \(challengeDescription)"
            case .explain(let latestCompiledCode, let challenge):
            let challengeDescription = challenge.body.toAttributedString().string
                return """
    This is the problem I am trying to solve in \(challenge.codehubProgrammingLanguage.rawValue): \n\(challengeDescription).\nCan you explain what's wrong in my solution:\n```\(latestCompiledCode)```\n
    """
            case .explainTopic(let collectionContent, let programmingLanguage):
                return """
    Please explain the topic of \(collectionContent.name) using \(programmingLanguage.rawValue)
    """
        }
    }

    var answerPrompts: [String] {
        switch self {
        case .provideSolution, .explain:
            return ["Yes, I’m all set", "Can I see an example?", "No, please elaborate", "Explain in Monkey🍌Terms"]
        case .explainTopic:
            return []
        }
    }

    func getAnalyticsEvent(string: String) -> AnalyticsEvent? {
        switch self {
        case .explain(_, let challengeDetail):
            return .explainMistakeClicked(challengeDetail.id, string)
        case .provideSolution(let challengeDetail):
            return .askAICLicked(challengeDetail.id, string)
        case .explainTopic: return nil
        }
    }

    var title: String {
        switch self {
        case .explain:
            return "Explain Mistake"
        case .provideSolution:
            return "Help Solve"
        case .explainTopic:
            return "Lessons"
        }
    }

    var showInput: Bool {
        switch self {
        case .explainTopic:
            return true
        default: return false
        }
    }
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
