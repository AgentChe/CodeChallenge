//
//  ChallengeDetails.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 14/02/2023.
//

import Foundation

struct ChallengeDetail: Codable, Equatable {
    let id: Int
    let dateCreated, dateModified: Double
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
    func toAttributedString() -> NSMutableAttributedString {
        guard let cleared = description.removingPercentEncoding else { return NSMutableAttributedString(string: description) }
        let data = cleared.replacingOccurrences(of: "\n", with: "<br>").data(using: .utf8)
        return try! NSMutableAttributedString(data: data!, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
    }
}
