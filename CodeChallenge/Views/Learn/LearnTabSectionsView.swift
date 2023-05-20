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
    let onElementTap: (LearnElement) -> Void
    let onOpenPremium: () -> Void
    let onJumpSection: (LearnSection) -> Void
    let onJumpSignUp: () -> Void

    var body: some View {
        if isLoading {
            SkeletonView()
        } else {
            content
        }
    }

    private var content: some View {
        ScrollViewReader(content: { proxy in
            LazyVGrid(
                columns: gridItemLayout,
                alignment: .leading,
                spacing: 19,
                pinnedViews: []) {
                    if !sections.isEmpty {
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
                                            .padding(.bottom, 6)
                                        HStack {
                                            Text(section.description)
                                                .font(.regular(size: 18))
                                                .foregroundColor(.CodeChallenge.white)
                                            Spacer()
                                        }
                                    }
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, 16)
                                    .background(.CodeChallenge.darkBlue)
                            ) {

                                ForEach(Array(section.contents.enumerated()), id: \.element.id) { (offset, element) in
                                    elementView(element, offset, section.contents.count, fromLeft: sectionOffset % 2 == 0, sectionOffset: sectionOffset)
                                        .id(element.id)
                                }
                            }
                        }
                        footerView
                    } else {
                        emptyView
                    }
                }
                .onAppear {
                    withAnimation {
                        proxy.scrollTo(currentProgressId)
                    }
                }
                .foregroundColor(.white)
                .padding(.top, 16)
                .onChange(of: currentProgressId) { _ in
                    withAnimation {
                        proxy.scrollTo(currentProgressId)
                    }
                }
        })
    }

    private var footerView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(UIColor.CodeChallenge.gray2), lineWidth: 6)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: CGFloat(learnSections?.passedLessonIds.count ?? 0) / CGFloat(learnSections?.allIds.count ?? 0))
                    .stroke(Color(UIColor.CodeChallenge.blue1), lineWidth: 8)
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(90))
                Image(programmingLanguage.rawValue)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 30)
            Text(learnSections?.lastSectionIsDone == true ? "You've made it!" : "You’re on the right track!")
                .font(.h3)
                .bold()
            Text(learnSections?.lastSectionIsDone == true ? "You've unlocked your certificate" : "Keep going and unlock your personalized certificate")
                .font(.regular(size: 18))
                .foregroundColor(.CodeChallenge.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            Button("Claim My Certificate") {
                if store.state.user.value?.isLoggedIn == true {
                    // FIXME: implement the popup
                } else {
                    onJumpSignUp()
                }
            }
            .padding(.bottom, 20)
            .buttonStyle(PrimaryButton(status: learnSections?.lastSectionIsDone == true ? .enabled : .disabled))
        }
        .padding(.horizontal, 25)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Text("\(programmingLanguage.rawValue.capitalized) lessons are cooking!")
                .font(.h3)
                .bold()
            Text("We are in the process of developing this section!")
                .font(.regular(size: 18))
                .foregroundColor(.CodeChallenge.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
        }
        .padding(.horizontal, 25)
    }

    private func elementView(_ element: LearnElement, _ position: Int, _ count: Int, fromLeft: Bool, sectionOffset: Int) -> some View {
        return HStack {
            Spacer()
                .frame(width: offset(position, count, fromLeft: fromLeft))
            VStack {
                image(element: element, position: position) {
                    if element.id != currentProgressId && position == 0 && learnSections?.passedLessonIds.contains(element.id) == false {
                        onJumpSection(sections[sectionOffset - 1])
                    } else {
                        onElementTap(element)
                    }
                }
                Text(element.title)
                    .font(.bodyText)
                    .multilineTextAlignment(.center)
            }
            .frame(width: .screenWidth/2)
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

    @ViewBuilder
    private func image(element: LearnElement, position: Int, onTapGesture: @escaping () -> Void) -> some View {
        if element.id == currentProgressId && learnSections?.passedLessonIds.contains(element.id) == false {
            ZStack {
                Ellipse()
                    .stroke(Color(UIColor.CodeChallenge.gray2), lineWidth: 6)
                    .frame(width: 95, height: 86)
                Ellipse()
                    .trim(from: 0, to: CGFloat(element.progress)/CGFloat(100))
                    .stroke(Color(UIColor.CodeChallenge.lessonQuizGreen), lineWidth: 8)
                    .frame(width: 86, height: 95)
                    .rotationEffect(.degrees(90))
                Image("learn_star")
                    .resizable()
                    .frame(width: 70, height: 65)
                    .padding(12)
                    .onTapGesture(perform: onTapGesture)
            }
        } else {
            if store.state.user.value?.isPremium == false && element.isPremium == true {
                Image("learn_premium")
                    .resizable()
                    .frame(width: 70, height: 65)
                    .padding(12)
                    .onTapGesture(perform: onOpenPremium)
            } else if learnSections?.passedLessonIds.contains(element.id) == true {
                Image("learn_star")
                    .resizable()
                    .frame(width: 70, height: 65)
                    .padding(12)
                    .onTapGesture(perform: onTapGesture)
            } else {
                if position == 0 {
                    Image("learn_jump")
                        .resizable()
                        .frame(width: 70, height: 65)
                        .padding(12)
                        .onTapGesture(perform: onTapGesture)
                } else {
                    Image("learn_disabled")
                        .resizable()
                        .frame(width: 70, height: 65)
                        .padding(12)
                }
            }
        }
    }
}

fileprivate struct SkeletonView: View {
    let gridItemLayout = [GridItem(.flexible(), spacing: 0)]

    var body: some View {
        LazyVGrid(
            columns: gridItemLayout,
            alignment: .leading,
            spacing: 19,
            pinnedViews: []) {
                Text("Learning Python")
                    .font(.pageNameH1)
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                Section(
                    header:
                        VStack(alignment: .leading, spacing: 12) {
                            Text("section.title")
                                .font(.h3)
                                .bold()
                                .padding(.bottom, 6)
                            HStack {
                                Text("section.description longer")
                                    .font(.regular(size: 18))
                                    .foregroundColor(.CodeChallenge.white)
                                Spacer()
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .background(.CodeChallenge.darkBlue)
                ) {

                    ForEach(0..<5) { element in
                        elementView(element, 5, fromLeft: true)
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.top, 16)
            .redacted(reason: .placeholder)
    }

    private func elementView(_ position: Int, _ count: Int, fromLeft: Bool) -> some View {
        return HStack {
            Spacer()
                .frame(width: offset(position, count, fromLeft: fromLeft))
            VStack {
                Image("learn_disabled")
                    .resizable()
                    .frame(width: 70, height: 65)
                    .padding(12)
                Text("element.title")
                    .font(.bodyText)
                    .multilineTextAlignment(.center)
            }
            .frame(width: .screenWidth/2)
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
