//
//  JumpHereContentsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 04/05/2023.
//

import Foundation
import SwiftUI

struct JumpHereContentsView: View {
    @EnvironmentObject var store: Store
    @Environment(\.presentationMode) var presentationMode
    let lessonCollection: LessonCollection?
    @State private var selection = 0
    @State private var currentProgress = 0
    @State private var challengesLoaded = false

    var enabledPages: [Lesson] {
        return lessonCollection?.getEnabledPages(basedOn: currentProgress) ?? []
    }

    var pages: [Lesson] {
        lessonCollection?.pages ?? []
    }

    var lessonCollections: [LearnElement] {
        let sections = store.state.learnSections[store.state.programmingLanguage]?.value?.contents ?? []
        return sections
            .reduce([LearnElement](), { partialResult, result in
            partialResult + result.contents
        })
    }

    var nextLessonCollectionId: Int? {
        guard let currentIndex = (lessonCollections.firstIndex(where: { $0.id == lessonCollection?.id })) else { return nil }
        let index = lessonCollections.index(after: currentIndex)
        return lessonCollections[index].id
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                HStack {
                    Image("cross")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    Spacer()
                }
                .padding(.leading, 16)

                ZStack {
                    Rectangle()
                        .fill(Color(UIColor.CodeChallenge.dustyBlue))
                        .frame(width: .screenWidth)
                    HStack {
                        RoundedCornersShape(corners: [.topRight, .bottomRight], radius: 3)
                            .fill(Color(UIColor.CodeChallenge.blue1))
                            .frame(width: .screenWidth * CGFloat(selection + 1)/CGFloat(pages.count + 1))
                        Spacer()
                    }
                }
                .frame(height: 6)
            }
            Group {
                if let collection = lessonCollection {
                    TabView(selection: $selection, content: {
                        ForEach(Array(enabledPages.enumerated()), id: \.offset) { (index, lesson) in
                            LessonView(lesson: lesson, lessonCollection: lessonCollection, hasPassedEntireLesson: false, onContinue: { updateProgresses in
                                if selection < pages.count - 1 {
                                    withAnimation {
                                        currentProgress = lesson.id
                                        selection += 1
                                    }
                                } else {
                                    presentationMode.wrappedValue.dismiss()
                                }
                                if updateProgresses {
                                    if collection.pages.last?.id == lesson.id, let id = nextLessonCollectionId {
                                        store.dispatch(UpdateLearningPathProgress(progress: id))
                                    }
                                }
                            })
                        }
                    })
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                } else {
                    EmptyView()
                }
            }
        }
        .background(.CodeChallenge.dark)
        .onAppear {
            loadChallengeDetails()
        }
    }

    private func loadChallengeDetails() {
        guard !challengesLoaded else { return }
        let contents = pages.reduce([LessonContent]()) { partialResult, lesson in
            return partialResult + lesson.content
        }
        for content in contents {
            challengesLoaded = true
            switch content {
            case .challenge(let id):
                store.dispatch(LoadChallengeDetails(id: id))
                store.dispatch(LoadChallengeProgress(challengeId: id, onComplete: nil))
            default: break
            }
        }
    }
}
