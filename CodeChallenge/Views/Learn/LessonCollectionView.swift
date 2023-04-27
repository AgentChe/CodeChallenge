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
        //        return lessonCollection?.pages.filter { $0.id <= (lessonCollection?.currentProgress ?? 0) } ?? []
        return lessonCollection?.pages ?? []
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
                            LessonView(lesson: lesson, onContinue: {
                                if selection < pages.count {
                                    withAnimation {
                                        selection += 1
                                    }
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
            store.dispatch(GetLessonCollection(element: homeElement))
        }
    }
}
