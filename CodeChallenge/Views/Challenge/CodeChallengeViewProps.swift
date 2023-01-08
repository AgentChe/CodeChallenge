//
//  CodeChallengeViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation

protocol CodeChallengeViewProps {
    var store: Store { get }
    var codeChallenge: Challenge { get }
}

extension CodeChallengeViewProps {
    var details: ChallengeDetail? {
        store.state.challengeDetails[codeChallenge.id]?.value
    }

    var detailsAreLoading: Bool {
        store.state.challengeDetails[codeChallenge.id]?.isLoading ?? false
    }

    var code: String {
        if let progress = store.state.challengeProgresses[codeChallenge.id]?.value {
            return progress.solution?.python ?? template
        } else {
            return template
        }
    }

    var taskInput: String? {
        "details?.body.input"
    }

    var taskOutput: String? {
        "details?.body.output"
    }

    var template: String {
        return details?.body.template ?? ""
    }

    var isLoading: Bool {
        return [
            store.state.challengeProgresses[codeChallenge.id]?.isLoading,
            store.state.challengeResults[codeChallenge.id]?.isLoading
        ].contains { $0 == true }
    }

    var output: String {
        return store.state.challengeResults[codeChallenge.id]?.value?.code.output.removingPercentEncoding ?? ""
    }

    var gotCompileError: Bool? {
        guard let statusCode = store.state.challengeResults[codeChallenge.id]?.value?.code.statusCode else { return nil }
        return statusCode == 1
    }

    var compilerTestCases: [ChallengeCompiledResult.UnitTest]? {
        return store.state.challengeResults[codeChallenge.id]?.value?.unitTests
    }

    var testCasesInputs: [Output] {
        return details?.unitTests.output ?? []
    }
    
    var testCases: [TestCase] {
        var result: [TestCase] = []
        for testCase in testCasesInputs {
            if let compilerResult = (compilerTestCases?.first { Int($0.id) == testCase.testId }) {
                let testCase = TestCase(id: testCase.testId,
                                        input: testCase.input,
                                        output: "\(compilerResult.output ?? "")",
                                        expectedOutput: testCase.expectedOutput,
                                        isFailed: compilerResult.outcome == .failed,
                                        isLocked: false)
                result.append(testCase)
            }
        }
        return result
    }

    var celebratedChallenges: [Int] {
        guard let array = UserDefaults.standard.array(forKey: "celebratedChallenges") as? [Int] else { return []}
        return array
    }

    func set(celebratedChallenge: ChallengeDetail) {
        var challenges = celebratedChallenges
        challenges.append(celebratedChallenge.id)
        UserDefaults.standard.set(challenges, forKey: "celebratedChallenges")
    }

    var programmingLanguage: ProgrammingLanguage {
        store.state.programmingLanguage
    }
}
