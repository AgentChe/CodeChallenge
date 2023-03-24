//
//  ChallengeFriendCodeChallengeViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 21/03/2023.
//

import Foundation

protocol ChallengeFriendCodeChallengeViewProps {
    var store: Store { get }
    var codeChallengeId: Int { get }
}

extension ChallengeFriendCodeChallengeViewProps {
    var details: ChallengeDetail? {
        store.state.challengeDetails[codeChallengeId]?.value
    }

    var isLoading: Bool {
        return [
            store.state.challengeProgresses[codeChallengeId]?.isLoading,
            store.state.challengeResults[codeChallengeId]?.isLoading
        ].contains { $0 == true }
    }

    var programmingLanguage: ProgrammingLanguage {
        details?.codehubProgrammingLanguage ?? .python
    }

    var code: String {
        if let progress = store.state.challengeProgresses[details?.id ?? 0]?.value {
            return progress.solution?.python ?? template
        } else {
            return template
        }
    }

    var template: String {
        return details?.body.template ?? ""
    }

    var account: Account? {
        store.state.account.value
    }

    var shouldShowPremiumPopup: Bool {
        details?.isPremium == true && account?.isPremium == false
    }

    var compilerTestCases: [ChallengeCompiledResult.UnitTest]? {
        return store.state.challengeResults[details?.id ?? 0]?.value?.unitTests
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
}
