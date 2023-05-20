//
//  LessonCollectionView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 02/04/2023.
//

import Foundation
import SwiftUI

struct LessonCollectionView: View, LessonCollectionViewProps {
    @EnvironmentObject var store: Store
    @Environment(\.presentationMode) var presentationMode
    let learnElement: LearnElement
    @State private var selection = 1
    @State private var challengesLoaded = false

    private var hasPassedEntireLesson: Bool {
        store.state.learnSections[store.state.programmingLanguage]?.value?.passedLessonIds.contains(learnElement.id) == true
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
                            .frame(width: .screenWidth * CGFloat(selection)/CGFloat(pages.count + 1))
                        Spacer()
                    }
                }
                .frame(height: 6)
            }
            if isLoading {
                SkeletonView()
            } else if let collection = lessonCollection {
                TabView(selection: $selection, content: {
                    ForEach(Array(enabledPages.enumerated()), id: \.offset) { (index, lesson) in
                        LessonView(lesson: lesson, lessonCollection: lessonCollection, hasPassedEntireLesson: hasPassedEntireLesson, onContinue: { updateProgresses in
                            if updateProgresses {
                                store.dispatch(UpdateClassProgress(progress: lesson.id, classId: collection.id))
                                if collection.pages.last?.id == lesson.id, let id = nextLessonCollectionId {
                                    store.dispatch(UpdateLearningPathProgress(progress: id))
                                } else {
                                    store.dispatch(GetLearnSections(programmingLanguage: programmingLanguage))
                                }
                            }
                            if selection >= pages.count {
                                presentationMode.wrappedValue.dismiss()
                            }
                        })
                        .tag(lesson.id)
                    }
                })
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            } else {
                EmptyView()
            }
        }
        .background(.CodeChallenge.dark)
        .onAppear {
            store.dispatch(GetLessonCollection(id: learnElement.id))
            if !enabledPages.isEmpty {
                if let index = (enabledPages.firstIndex { $0.id == currentProgress }) {
                    selection = index + 2
                } else {
                    selection = 1
                }
                loadChallengeDetails()
            }
        }
        .onChange(of: enabledPages, perform: { _ in
            withAnimation {
                if let index = (enabledPages.firstIndex { $0.id == currentProgress }) {
                    selection = index + 2
                } else {
                    selection = 1
                }
            }
            loadChallengeDetails()
        })
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

fileprivate struct SkeletonView: View {
    @State private var selection = 0
    var body: some View {
        TabView(selection: $selection, content: {
            VStack(alignment: .leading, spacing: 10) {
                Text("a bit of big random text")
                    .font(.h3)
                Text("a bit of bigger more random and more random text")
                    .font(.bodyText)
                Spacer()
            }
            .padding(20)
        })
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .redacted(reason: .placeholder)
    }
}
