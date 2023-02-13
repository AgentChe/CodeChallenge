//
//  ChallengeCompiledResult.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 14/02/2023.
//

import Foundation

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
