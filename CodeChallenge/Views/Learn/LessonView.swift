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
    let hasPassedEntireLesson: Bool
    let onContinue: (_ updateProgresses: Bool) -> Void

    @State private var quizAnswers: [(LessonContent, [String])] = []
    @State private var challengeAnswers: [Int: String] = [:]

    @State private var presentResult = false
    @State private var presentQuizResultPopup = false
    @State private var presentCodeCompiledPopup = false

    var buttonStatus: PrimaryButton.Status {
        if quizAnswers.isEmpty { return .enabled }
        return quizAnswers.map { $0.1.isEmpty }.contains(true) ? PrimaryButton.Status.disabled : PrimaryButton.Status.enabled
    }

    var hasPassedThisLesson: Bool {
        if hasPassedEntireLesson { return true }
        guard let enabledPages = lessonCollection?.enabledPages,
              let index = (enabledPages.firstIndex { $0.id == lesson.id }) else { return false }
        return index < enabledPages.count - 1
    }

    var challengeResults: [Int: Resolvable<ChallengeCompiledResult>] {
        store.state.challengeResults
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(lesson.content.enumerated()), id: \.offset) { (offset, lessonContent) in
                        switch lessonContent {
                        case .text(let text):
                            LessonTextView(text: text)
                        case .code(let code, let pl):
                            LessonCodeView(code: code, pl: pl)
                        case .composeCodeQuiz(let text, let options, let winning):
                            QuizComposeCodeView(text: text, options: options, winning: winning, passed: hasPassedThisLesson) { options in
                                modifyQuizAnswersDict(lessonContent: lessonContent, result: options)
                            }
                        case .chooseAnswerQuiz(let text, let options, let winning):
                            QuizSelectionView(text: text, options: options, winning: winning, passed: hasPassedThisLesson) { options in
                                modifyQuizAnswersDict(lessonContent: lessonContent, result: options)
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
                                challengeAnswers[id] = code
                            })
                            .id(id)
                        default: EmptyView()
                        }
                    }
                    Spacer()
                }
            }
            Spacer()
            ZStack {
                if presentResult {
                    if presentQuizResultPopup {
                        continuePopup()
                            .transition(.move(edge: .bottom))
                    } else if presentCodeCompiledPopup {
                        codeChallengeOutputView()
                            .transition(.move(edge: .bottom))
                    }
                }
                VStack {
                    Spacer()
                    Button("Continue") {
                        if !lessonHasSolvableContent ||
                            (presentResult && ((presentQuizResultPopup && quizesPassed) ||
                                               (presentCodeCompiledPopup && codeCompileResult.0 == "successful!"))) {
                            onContinue(!hasPassedThisLesson)
                        } else {
                            for challengeId in challengeAnswers.keys {
                                store.dispatch(UpdateChallengeProgress(challengeId: challengeId,
                                                                       solution: challengeAnswers[challengeId] ?? "",
                                                                       compile: true,
                                                                       programmingLanguage: store.state.programmingLanguage, language: "en"
                                                                      ))
                            }

                            withAnimation {
                                if !quizAnswers.isEmpty {
                                    presentQuizResultPopup = true
                                }
                                presentResult = true
                            }
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
            setupAnswersDict()
        }
        .padding(.top, 20)
        .onChange(of: challengeResults) { newValue in
            if !presentCodeCompiledPopup {
                withAnimation {
                    presentCodeCompiledPopup = true
                }
            }
        }
    }
}

extension LessonView {
    private func setupAnswersDict() {
        for lesson in lesson.content {
            switch lesson {
            case .composeCodeQuiz, .chooseAnswerQuiz:
                quizAnswers.append((lesson, []))
            case .challenge:
                break
            default: break
            }
        }
    }

    private func modifyQuizAnswersDict(lessonContent: LessonContent, result items: [String]) {
        presentResult = false
        quizAnswers.removeAll(where: { $0.0 == lessonContent })
        quizAnswers.append((lessonContent, items))
    }

    private func continuePopup() -> some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color(quizesPassed ? UIColor.CodeChallenge.lessonQuizGreen : UIColor.CodeChallenge.lessonQuizRed))
                .frame(height: 4)
            Text(!quizesPassed ? "Try again": "You are correct!")
                .foregroundColor(Color(!quizesPassed ? UIColor.CodeChallenge.lessonQuizRed : UIColor.CodeChallenge.lessonQuizGreen))
                .font(.bodyText)
                .padding(.leading, 20)
            Spacer()
        }
        .frame(width: .screenWidth, height: 120)
        .background {
            Rectangle()
                .fill(Color(UIColor.CodeChallenge.dustyBlue))
        }
    }

    private var quizesPassed: Bool {
        var result = true
        for item in quizAnswers {
            switch item.0 {
            case .chooseAnswerQuiz(_, _, let winning):
                if winning.sorted() != item.1.sorted() {
                    result = false
                }
            case .composeCodeQuiz(_, _, let winning):
                if winning != item.1 {
                    result = false
                }
            default: continue
            }
        }
        return result
    }
}


extension LessonView {
    private func codeChallengeOutputView() -> some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 12)
            HStack {
                Text(codeCompileResult.0.capitalized)
                    .foregroundColor(codeCompileResult.1)
                    .multilineTextAlignment(.leading)
                    .font(.h5)
                Spacer()
            }
            .padding(.leading, 20)
            Spacer()
        }
        .frame(width: .screenWidth, height: 120)
        .background {
            Rectangle()
                .fill(Color(UIColor.CodeChallenge.gray1))
        }
    }

    private var codeCompileResult: (String, Color) {
        for id in lesson.challengeIds {
            if challengeResults[id]?.isLoading == true {
                return ("compiling...", Color(UIColor.white))
            } else {
                let testCases = challengeResults[id]?.value?.unitTests ?? []
                if (testCases.filter { $0.outcome == .passed }.count == testCases.count), !testCases.isEmpty {
                    return ("successful!", Color(UIColor.CodeChallenge.lessonQuizGreen))
                } else {
                    return ("compiler failed!", Color(UIColor.CodeChallenge.lessonQuizRed))
                }
            }
        }
        return ("success", Color(UIColor.CodeChallenge.lessonQuizGreen))
    }
}

extension LessonView {
    var lessonHasSolvableContent: Bool {
        for item in lesson.content {
            switch item {
            case .challenge, .composeCodeQuiz, .chooseAnswerQuiz:
                return true
            default: continue
            }
        }
        return false
    }
}
