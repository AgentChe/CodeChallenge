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
    let homeElement: HomeElement
    @State private var selection = 1

    var pages: [Lesson] {
        lessonCollection?.enabledPages ?? []
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
            Group {
                if let collection = lessonCollection {
                    TabView(selection: $selection, content: {
                        ForEach(Array(pages.enumerated()), id: \.offset) { (index, lesson) in
                            LessonView(lesson: lesson, lessonCollection: lessonCollection, onContinue: {
                                if selection < pages.count {
                                    withAnimation {
                                        selection += 1
                                    }
                                } else {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            })
                            .tag(lesson.id)
//                            .contentShape(Rectangle())
//                            .gesture(nil)
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
            store.dispatch(GetLessonCollection(id: homeElement.id))
            if !pages.isEmpty {
                selection = pages.count
                loadChallengeDetails()
            }
        }
        .onChange(of: pages, perform: { value in
            selection = pages.count
            loadChallengeDetails()
        })
    }

    private func loadChallengeDetails() {
        let contents = pages.reduce([LessonContent]()) { partialResult, lesson in
            return partialResult + lesson.content
        }
        for content in contents {
            switch content {
            case .challenge(let id):
                store.dispatch(LoadChallengeDetails(id: id))
                store.dispatch(LoadChallengeProgress(challengeId: id, onComplete: nil))
            default: break
            }
        }
    }
}
