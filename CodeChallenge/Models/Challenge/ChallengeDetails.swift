//
//  ChallengeDetails.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 14/02/2023.
//

import Foundation

struct ChallengeDetail: Codable, Equatable {
    let id: Int
    let icon, difficulty: String
    let time: Int
    let isPremium: Bool
    let xp: Int
    let published: Bool
    let unitTests: UnitTests
    let solutionCode: SolutionCode
    let name: String
    let body: Body
    let programmingLanguage: String
    let aiGenerated: [AIGenerated]?
}

extension ChallengeDetail {
    var codehubProgrammingLanguage: ProgrammingLanguage {
        switch programmingLanguage {
        case "jv": return .java
        case "sw": return .swift
        default: return .python
        }
    }
}

struct AIGenerated: Codable, Equatable {
    let comment: String
    let code: [String]
}

// MARK: - BodyPython
struct Body: Codable, Equatable {
    let description, template, input, output: String
}

struct SolutionCode: Codable, Equatable {
    let code: String?
}

struct UnitTests: Codable, Equatable {
    let test: String
    let output: [Output]
}

struct Output: Codable, Equatable {
    let testId: Int
    let input: String
    let expectedOutput: String
}

extension Body {
    // NOTE: HTML parsing spins a nested WebKit run loop and must run on the main
    // thread AND outside any SwiftUI view-update transaction. Never call this from
    // a `body`/`updateUIView`; compute it from `.task`/`.onAppear` and cache it.
    func toAttributedString() -> NSMutableAttributedString {
        let cleared = description.removingPercentEncoding ?? description
        guard let data = cleared.replacingOccurrences(of: "\n", with: "<br>").data(using: .utf8),
              let parsed = try? NSMutableAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
              ) else {
            return NSMutableAttributedString(string: cleared)
        }
        return parsed
    }
}
