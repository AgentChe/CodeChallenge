//
//  CodeChallengeTestCasesView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/08/2022.
//

import SwiftUI

struct CodeChallengeTestCasesView: View {
    @EnvironmentObject var store: Store
    
    let details: ChallengeDetail
    let onSeeSolution: (() -> Void)?
    let onTryAgain: () -> Void
    let onContinue: () -> Void
    @State private var expandedTestCases: [TestCase] = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                if !testCases.isEmpty {
                    ForEach(Array(testCases.enumerated()), id: \.offset) { index, testCase in
                        testCaseView(index: index, testCase: testCase)
                            .onTapGesture {
                                guard !testCase.isLocked else { return }
                                if (expandedTestCases.contains { $0.id == testCase.id }) {
                                    expandedTestCases = expandedTestCases.filter { $0.id != testCase.id }
                                } else {
                                    expandedTestCases.append(testCase)
                                }
                            }
                    }
                }

                if showsSolution {
                    seeSolutionView
                }

                if !testCases.isEmpty {
                    Spacer()

                    if (testCases.filter { $0.isFailed == false }.count == testCases.count) {
                        Button("Continue") {
                            onContinue()
                        }
                        .buttonStyle(PrimaryButton())
                    } else {
                        Button("Try Again") {
                            onTryAgain()
                        }
                        .buttonStyle(PrimaryButton())
                    }
                }
            }
        }
        .background(.CodeChallenge.dark)
        .padding(.horizontal, 25)
        .padding(.vertical, 30)
    }

    private func testCaseView(index: Int, testCase: TestCase) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.CodeChallenge.gray2))
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(testCase.isFailed ? "test_case_fail" : "test_case_success")
                        .opacity(testCase.isLocked ? 0.5 : 1)
                    Text("Test case #\(index + 1)")
                        .foregroundColor(.white)
                        .opacity(testCase.isLocked ? 0.5 : 1)
                        .font(.h5)
                    Spacer()
                    if testCase.isLocked {
                        Image("lock")
                    } else {
                        Image(expandedTestCases.contains { $0.id == testCase.id } ? "up_arrow" : "down_arrow")
                    }
                }
                .padding(.vertical, 23)

                if (expandedTestCases.contains { $0.id == testCase.id }) {
                    VStack(alignment: .leading, spacing: 15) {
                        resultItemView(title: "Input", value: testCase.input, color: .CodeChallenge.tabBar)
                        resultItemView(title: "Output", value: testCase.output, color: .CodeChallenge.tabBar)
                        resultItemView(title: "Expected output", value: testCase.expectedOutput, color: .CodeChallenge.tabBar)
                            .padding(.bottom, 15)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func resultItemView(title: String, value: String?, color: UIColor) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .foregroundColor(.white)
                .font(.h5)

            HStack {
                Text(value ?? "")
                    .font(.bodyText)
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 4)
                Spacer()
            }
            .background (
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(color))
            )
        }
    }

    private var seeSolutionView: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.CodeChallenge.background))
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                    .frame(height: 0)
                Text("Need help?")
                    .font(.h2)
                    .padding(.horizontal, 20)
                Text("No worries, we got you covered! Just tap to see the solution.")
                    .font(.smallText)
                    .padding(.horizontal, 20)
                ZStack {
                    RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 10)
                        .fill(Color(.CodeChallenge.green))
                        .frame(height: 38)
                    HStack {
                        Text("See Solution")
                            .font(.button)
                            .padding(.leading, 15)
                        Spacer()
                    }
                }
                .onTapGesture {
                    onSeeSolution?()
                }
            }
            .foregroundColor(.white)
        }
    }
}

extension CodeChallengeTestCasesView {
    var compilerTestCases: [ChallengeCompiledResult.UnitTest]? {
        return store.state.challengeResults[details.id]?.value?.unitTests
    }

    var testCasesInputs: [Output] {
        return details.unitTests.output
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

    var showsSolution: Bool {
        details.solutionCode.code != nil && onSeeSolution != nil
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
