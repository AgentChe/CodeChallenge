//
//  LessonView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 02/04/2023.
//

import Foundation
import SwiftUI

struct LessonView: View {
    @EnvironmentObject var store: Store
    let lesson: Lesson
    let lessonCollection: LessonCollection?
    let onContinue: () -> Void
    @State private var resultDict: [(LessonContent, [String])] = []
    @State private var presentContinuePopup = false
    @State private var presentResultStatus = false
    @State private var presentCodeChallengeOutputView = false

    var buttonStatus: PrimaryButton.Status {
        if resultDict.isEmpty { return .enabled }
        return resultDict.map { $0.1.isEmpty }.contains(true) ? PrimaryButton.Status.disabled : PrimaryButton.Status.enabled
        return .enabled
    }

    var hasPassedThisLesson: Bool {
        guard let enabledPages = lessonCollection?.enabledPages,
            let index = (enabledPages.firstIndex { $0.id == lesson.id }) else { return false }
        return index < enabledPages.count - 1
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(lesson.content.enumerated()), id: \.offset) { (_, lessonContent) in
                        switch lessonContent {
                        case .text(let text):
                            LessonTextView(text: text)
                        case .code(let code, let pl):
                            LessonCodeView(code: code, pl: pl)
                        case .composeCodeQuiz(let text, let options, let winning):
                            QuizComposeCodeView(text: text, options: options, winning: winning, passed: hasPassedThisLesson) { options in
                                modifyResultDict(lessonContent: lessonContent, result: options)
                            }
                        case .chooseAnswerQuiz(let text, let options, let winning):
                            QuizSelectionView(text: text, options: options, winning: winning, passed: hasPassedThisLesson) { options in
                                modifyResultDict(lessonContent: lessonContent, result: options)
                            }
                        case .image(let image):
                            NetworkImage(viewModel:
                                    .init(url: image,
                                          store: store),
                                         size: .init(
                                            width: .screenWidth - 40,
                                            height: .screenHeight / 4), contentMode: .fit)
                            .padding(.horizontal, 20)
                        case .heading(let text):
                            Text(text)
                                .foregroundColor(.white)
                                .font(.h2)
                                .padding(.horizontal, 20)
                        case .challenge(let id):
                            QuizChallengeView(id: id, onCodeChange: { code in
                                modifyResultDict(lessonContent: lessonContent, result: [code])
                            })
                        default: EmptyView()
                        }
                    }
                    Spacer()
                }
            }
            Spacer()
            ZStack {
                if presentCodeChallengeOutputView {
                    codeChallengeOutputView()
                }
                if presentContinuePopup, !presentCodeChallengeOutputView {
                    continuePopup()
                        .transition(.move(edge: .bottom))
                }
                VStack {
                    Spacer()
                    Button("Continue") {
                        if let challengeInformation = challengeInformation() {
                            store.dispatch(UpdateChallengeProgress(challengeId: challengeInformation.0,
                                                                   solution: challengeInformation.1,
                                                                   compile: true,
                                                                   programmingLanguage: .python, language: "en"
                                                                  ))
                        }
                        if presentResultStatus, resultStatus() == "success" {
                            store.dispatch(UpdateClassProgress(progress: lesson.id, classId: lessonCollection?.id ?? 0))
                            onContinue()
                        } else if !resultDict.isEmpty {
                            withAnimation {
                                presentResultStatus = true
                                presentContinuePopup = true
                            }
                        } else {
                            onContinue()
                        }
                    }
                    .disabled(buttonStatus == .disabled)
                    .buttonStyle(PrimaryButton(status: buttonStatus))
                    .padding(.horizontal, 20)
                    Spacer()
                        .frame(height: 20)
                }
                .frame(height: 120)
            }
        }
        .onAppear {
            setupResultDict()
        }
        .padding(.top, 20)
        .onChange(of: store.state.challengeResults) { newValue in
            for item in resultDict {
                switch item.0 {
                case .challenge(let id):
                    let testCases = newValue[id]?.value?.unitTests ?? []
                    if (testCases.filter { $0.outcome == .passed }.count == testCases.count), !testCases.isEmpty {
                        presentCodeChallengeOutputView = true
                    }
                default: break
                }
            }
        }
    }

    private func setupResultDict() {
        for lesson in lesson.content {
            switch lesson {
            case .composeCodeQuiz, .chooseAnswerQuiz, .challenge:
                resultDict.append((lesson, []))
            default: break
            }
        }
    }

    private func modifyResultDict(lessonContent: LessonContent, result items: [String]) {
        presentResultStatus = false
        resultDict.removeAll(where: { $0.0 == lessonContent })
        resultDict.append((lessonContent, items))
    }

    private func continuePopup() -> some View {
        VStack {
            if presentResultStatus {
                Rectangle()
                    .fill(Color(resultStatus() == "success" ? UIColor.CodeChallenge.lessonQuizGreen : UIColor.CodeChallenge.lessonQuizRed))
                    .frame(height: 4)
            }
            Spacer()
        }
        .frame(width: .screenWidth, height: 120)
        .background {
            Rectangle()
                .fill(Color(UIColor.CodeChallenge.dustyBlue))
        }
    }

    private func codeChallengeOutputView() -> some View {
        VStack {
            Text("Successfully completed")
            Spacer()
        }
        .frame(width: .screenWidth, height: 120)
        .background {
            RoundedCornersShape(corners: [.topRight, .topLeft], radius: 10)
                .fill(Color(UIColor.CodeChallenge.gray1))
        }
    }

    private func resultStatus() -> String {
        for item in resultDict {
            switch item.0 {
            case .chooseAnswerQuiz(_, _, let winning):
                return winning.sorted() == item.1.sorted() ? "success" : "fail"
            case .composeCodeQuiz(_, _, let winning):
                return winning.sorted() == item.1.sorted()  ? "success" : "fail"
            case .challenge(let id):
                return "running..."
            default: continue
            }
        }
        return "success"
    }

    private func challengeInformation() -> (Int, String)? {
        for item in resultDict {
            switch item.0 {
            case .challenge(let id):
                return (id, item.1.first ?? "")
            default: continue
            }
        }
        return nil
    }
}
