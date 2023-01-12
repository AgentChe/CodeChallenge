//
//  ChallengeGroups.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation
import UIKit

struct ChallengeGroup: Codable, Equatable {
    enum Style: String, Codable {
        case large
        case medium
        case collection
    }
    let name: String
    let description: String
    let challenges: [Challenge]
    let style: Style
    let id: String?
}

struct Challenge: Codable {
    struct Tag: Codable, Hashable {
        let name: String
        let color: String
    }
    let id: Int
    let name: String
    let tags: [Tag]
    let difficulty: String
    let isPremium: Bool
    let xp: Int
    let progress: String
    let isNew: Bool
}

extension Challenge: Equatable {}

extension Challenge {
    var isHard: Bool {
        difficulty.lowercased() == "hard"
    }

    var isMedium: Bool {
        difficulty.lowercased() == "medium"
    }

    var isEasy: Bool {
        difficulty.lowercased() == "easy"
    }

    var allTags: [Tag] {
        [Tag(name: difficulty.lowercased().capitalized, color: difficulty.lowercased().capitalized.toColorHex())] + tags
    }
}

extension Challenge {
    var tagsDescription: String {
        tags.reduce("") { partialResult, result in
            return partialResult + " #\(result.name)"
        }
    }
}


struct ChallengeProgress: Codable {
    struct Solution: Codable {
        let python: String
    }
    let id: Int?
    let dateCreated, dateModified: Double?
    let challengeId: Int?
    let userId: Int?
    let type: String?
    let progress: CGFloat?
    let solution: Solution?
    let spentTime: Int?
}

struct TestCase {
    let id: Int
    let input: String?
    let output: String?
    let expectedOutput: String?
    let isFailed: Bool
    let isLocked: Bool
}

extension String {
    func toColorHex() -> String {
        if self == "Easy" {
            return "20BB82"
        } else if self == "Medium" {
            return "FFC169"
        } else if self == "Hard" {
            return "FF7A4F"
        } else {
            return "806FFF"
        }
    }
}


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
    let tags: Hint
    let body: Body
    let hint, solution: Hint
    let programmingLanguage: String
}

extension ChallengeDetail {
    var codehubProgrammingLanguage: ProgrammingLanguage {
        switch programmingLanguage {
        case "jv": return .java
        default: return .python
        }
    }
}

// MARK: - BodyPython
struct Body: Codable, Equatable {
    let description, template, input, output: String
}

extension Body {
    func toAttributedString() -> NSMutableAttributedString {
        guard let cleared = description.removingPercentEncoding else { return NSMutableAttributedString(string: description) }
        let data = cleared.replacingOccurrences(of: "\n", with: "<br>").data(using: .utf8)
        return try! NSMutableAttributedString(data: data!, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
    }
}

// MARK: - Hint
struct Hint: Codable, Equatable {
}

// MARK: - SolutionCode
struct SolutionCode: Codable, Equatable {
    let code: String?
}

// MARK: - UnitTests
struct UnitTests: Codable, Equatable {
    let test: String
    let output: [Output]
}

struct Output: Codable, Equatable {
    let testId: Int
    let input: String
    let expectedOutput: String
}

struct ChallengeCompiledResult: Codable, Equatable {
    struct Code: Codable, Equatable {
        let statusCode: Int
        let output: String
    }

    struct UnitTest: Codable, Equatable {
        let id: String
        let output: String?
        let outcome: Outcome
    }

    let code: Code
    let unitTests: [UnitTest]
}

extension ChallengeCompiledResult {
    var isSuccesful: Bool {
        unitTests.filter { $0.outcome == .passed }.count == unitTests.count && unitTests.count != 0
    }
}

enum Outcome: String, Codable, Equatable {
    case passed
    case failed
}
