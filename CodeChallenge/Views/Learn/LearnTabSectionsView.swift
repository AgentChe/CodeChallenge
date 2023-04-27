//
//  LearnTabSectionsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 04/04/2023.
//

import Foundation
import SwiftUI

struct LearnTabSectionsView: View, LearnTabSectionsViewProps {
    @EnvironmentObject var store: Store
    let gridItemLayout = [GridItem(.flexible(), spacing: 0)]
    let onElementTap: (HomeElement) -> Void

    var programmingLanguage: ProgrammingLanguage {
        store.state.programmingLanguage
    }

    var body: some View {
        content
            .onAppear {
                store.dispatch(GetHomeSections(programmingLanguage: programmingLanguage))
            }
    }

    private var content: some View {
        LazyVGrid(
            columns: gridItemLayout,
            alignment: .leading,
            spacing: 27,
            pinnedViews: []) {
                Text("Learning \(programmingLanguage.rawValue.capitalized)")
                    .font(.pageNameH1)
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                ForEach(Array(sections.enumerated()), id: \.offset) { (sectionOffset, section) in
                    Section(
                        header:
                            VStack(alignment: .leading, spacing: 12) {
                                Text(section.title)
                                    .font(.h3)
                                    .bold()
//                                    .padding(.leading, 10.0)
                                //                                Rectangle()
                                //                                    .fill(Color(UIColor.CodeChallenge.white.withAlphaComponent(0.1)))
                                //                                    .frame(width: .screenWidth, height: 1)
                                //                                    .padding(.bottom, 6)
                                HStack {
                                    Text("a little bit of description that is long a lit bit")
                                        .font(.regular(size: 18))
                                        .foregroundColor(.CodeChallenge.white)
                                    Spacer()
                                }
//                                .padding(.leading, 10.0)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 16)
                            .background(.CodeChallenge.darkBlue)
                    ) {

                        ForEach(Array(section.contents.enumerated()), id: \.element.id) { (offset, element) in
                            //                            homeViewElementView(offset: offset, sectionOffset: sectionOffset, section: section, collection: collection)
                            //                                .onTapGesture {
                            //                                    onCollectionTap?(collection)
                            //                                }
                            elementView(element, offset, section.contents.count, fromLeft: sectionOffset % 2 == 0)
                        }
                    }
                }
                footerView
            }
            .foregroundColor(.white)
            .padding(.top, 16)
    }

    private var footerView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(UIColor.CodeChallenge.gray2), lineWidth: 6)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0.25, to: 0.6)
                    .stroke(Color(UIColor.CodeChallenge.blue1), lineWidth: 8)
                    .frame(width: 120, height: 120)
                Image(programmingLanguage.rawValue)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 30)
            Text("You doing fine!")
                .font(.h3)
                .bold()
            Text("a little bit of description that is long a lit bit")
                .font(.regular(size: 18))
                .foregroundColor(.CodeChallenge.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            Button("Get certificate") {

            }
            .padding(.bottom, 20)
            .buttonStyle(PrimaryButton(status: .disabled))
        }
        .padding(.horizontal, 25)
    }

    private func elementView(_ element: HomeElement, _ position: Int, _ count: Int, fromLeft: Bool) -> some View {
        return HStack {
            Spacer()
                .frame(width: offset(position, count, fromLeft: fromLeft))
            VStack {
                //                NetworkImage(
                //                    viewModel: .init(url: "",
                //                                     store: store,
                //                                     placeholder: .init(named: "placeholder_image"),
                //                                     showsPlaceholderInitially: true,
                //                                     cacheEnabled: false),
                //                    animated: false,
                //                    size: .init(width: 60, height: 60)
                //                )
                ZStack {
                    Ellipse()
                        .stroke(Color(UIColor.CodeChallenge.gray2), lineWidth: 6)
                        .frame(width: 95, height: 86)
                    Ellipse()
                        .trim(from: 0.75, to: 1)
                        .stroke(Color(UIColor.CodeChallenge.lessonQuizGreen), lineWidth: 8)
                        .frame(width: 95, height: 86)
                    Image("home_test_icon")
                        .resizable()
                        .frame(width: 70, height: 65)
                        .padding(12)
                }
                Text(element.title)
                    .multilineTextAlignment(.center)
            }
            .frame(width: .screenWidth/2)
            .onTapGesture(perform: {
                onElementTap(element)
            })
            Spacer()
        }
        .padding(.vertical, 10)
    }

    private func offset(_ position: Int, _ count: Int, fromLeft: Bool) -> CGFloat {
        let middle = .screenWidth/4
        let delta = .screenWidth/CGFloat(count * 2)
        if position == 0 {
            return middle
        } else {
            if !fromLeft {
                if CGFloat(position - 1) < ceil(CGFloat((count - 1)/2)) {
                    return middle - CGFloat(position) * delta
                } else {
                    return middle - CGFloat((count - position)) * delta
                }
            } else {
                if CGFloat(position - 1) < ceil(CGFloat((count - 1)/2)) {
                    return middle + CGFloat(position) * delta
                } else {
                    return middle + CGFloat((count - position)) * delta
                }
            }
        }
    }
}
