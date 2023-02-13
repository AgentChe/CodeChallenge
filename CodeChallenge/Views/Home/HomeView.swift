//
//  NewHomeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/11/2022.
//

import Foundation
import SwiftUI
import UIKit
import Paywall

struct HomeView: View, HomeViewProps {
    let gridItemLayout = [GridItem(.flexible(), spacing: 0)]
    @EnvironmentObject var store: Store
    let humanLanguage: String
    let onCollectionTap: ((ChallengeCollection, ChallengeSection) -> Void)?
    @State private var showPaywall = false
    @State private var showProgrammingLanguagePopup = false

    var body: some View {
        DoodledView {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Code Challenges")
                        .font(.pageNameH1)
                        .foregroundColor(.white)
                        .padding(.bottom, 16)
                        .padding(.leading, 16)
                    if isLoading {
                        SkeletonView()
                    } else {
                        sectionsView
                    }
                }

                if showProgrammingLanguagePopup {
                    Rectangle()
                        .fill(Color.black)
                        .opacity(0.85)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showProgrammingLanguagePopup = false
                            }
                        }
                    changeLanguagePopup
                        .transition(.move(edge: .bottom).animation(.easeInOut(duration: 0.3)))
                        .zIndex(3)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 10) {
                    LanguagePickerIconView()
                        .onTapGesture {
                            withAnimation {
                                showProgrammingLanguagePopup = true
                            }
                        }
                    DefaultXPView(
                        xpText: "\(xp)",
                        backgroundColor: .CodeChallenge.dark,
                        xpIconColor: "white",
                        strokeColor: .CodeChallenge.blue1
                    )
                }
            }
        }
        .onChange(of: programmingLanguage) { newValue in
            store.dispatch(LoadHomeSections(language: newValue))
        }
    }

    private var changeLanguagePopup: some View {
            VStack {
                Spacer()
                ZStack(alignment: .leading) {
                    VStack(spacing: 16) {
                        Spacer()
                            .frame(height: 10)
                        Text("Choose Language")
                            .font(.h2)
                            .padding(.horizontal, 4)
                        ForEach(ProgrammingLanguage.allCases, id: \.rawValue) { language in
                            languageView(language: language)
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    store.dispatch(ChangeProgrammingLanguage(language: language))
                                    store.dispatch(LoadRecommendedChallenges())
                                    withAnimation {
                                        showProgrammingLanguagePopup = false
                                    }
                                }
                                .contentShape(Rectangle())
                        }
                        Button("Cancel") {
                            withAnimation {
                                showProgrammingLanguagePopup.toggle()
                            }
                        }
                        .foregroundColor(.white.withAlphaComponent(0.6))
                        .font(.smallText)
                        .padding(.bottom, 20)
                    }
                    .foregroundColor(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.CodeChallenge.background))
                    }
                }
                .padding(.horizontal, 16)
                Spacer()
            }
            .frame(width: .screenWidth)
    }

    private func languageView(language: ProgrammingLanguage) -> some View {
        HStack(spacing: 12) {
            Image(language.rawValue)
                .resizable()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 7) {
                Text(language.rawValue.capitalized)
                    .font(.h5)
                Text(language.shortDescription)
                    .font(.smallText)
                    .foregroundColor(.white.withAlphaComponent(0.6))
            }
            Spacer()
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(UIColor.CodeChallenge.purple), lineWidth: 1.2)
        }
    }

    private var sectionsView: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: gridItemLayout,
                alignment: .leading,
                spacing: 0,
                pinnedViews: []) {
                    ForEach(Array((sections ?? []).enumerated()), id: \.offset) { (sectionOffset, section) in
                        Section(
                            header:
                                Text(section.name)
                                .font(.h3)
                            .bold()
                            .padding(.leading, 10.0)
                            .padding(.bottom, 16)
                        ) {
                            ForEach(Array(section.collections.enumerated()), id: \.element.id) { (offset, collection) in
                                homeViewElementView(offset: offset, sectionOffset: sectionOffset, section: section, collection: collection)
                                    .onTapGesture {
                                        onCollectionTap?(collection, section)
                                    }
                            }
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
        }
        .padding(.top, 16)
    }

    private func homeViewElementView(offset: Int, sectionOffset: Int, section: ChallengeSection, collection: ChallengeCollection) -> some View {
        HomeViewElementView(model: collection,
                               progressImageName: progressImageName(index: offset, sectionIndex: sectionOffset),
                               progressTopInset: progressTopInset(index: offset, sectionIndex: sectionOffset),
                               progressBottomInset: progressBottomInset(index: offset, sectionIndex: sectionOffset),
                               progressPreviousPeaceHeight: progressPreviousPeaceHeight(index: offset, sectionIndex: sectionOffset),
                               expectedHeight: expectedHeight(index: offset, sectionIndex: sectionOffset),
                               previousModel: section.collections.element(at: offset - 1),
                               nextModel: section.collections.element(at: offset + 1))
    }
}

struct HomeViewElementView: View {
    @EnvironmentObject var store: Store
    let model: ChallengeCollection
    let progressImageName: String
    let progressTopInset: CGFloat
    let progressBottomInset: CGFloat
    let progressPreviousPeaceHeight: CGFloat
    let expectedHeight: CGFloat

    let previousModel: ChallengeCollection?
    let nextModel: ChallengeCollection?

    var body: some View {
        HStack {
            Spacer()
                .frame(width: 1)

            ZStack {
                HStack {
                    Spacer()
                        .frame(width: 3)
                    progressView
                    Spacer()
                        .frame(width: 3)
                }
                if model.progress == 100 {
                    completionView
                }
            }

            Spacer()
                .frame(width: 9)

            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(Color(UIColor.CodeChallenge.dark))
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(
                            Color(model.progress > 0 ? (model.progress == 100 ? .CodeChallenge.blue1 : .CodeChallenge.white) : .CodeChallenge.gray1),
                                lineWidth: 1.5
                        )
                    HStack(spacing: 0) {
                        VStack(alignment: .leading) {
                            if model.isNew {
                                NewLabelView()
                                    .padding(.bottom, 9)
                                Text(model.name)
                                    .font(.h4)
                                    .multilineTextAlignment(.leading)
                                Text(model.description)
                                    .font(.smallText)
                                    .foregroundColor(Color(UIColor.white.withAlphaComponent(0.6)))
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                                    .padding(.top, 3)
                            } else {
                                Text(model.name)
                                    .font(.h4)
                                    .multilineTextAlignment(.leading)
                                Text(model.description)
                                    .font(.smallText)
                                    .foregroundColor(Color(UIColor.white.withAlphaComponent(0.6)))
                                    .multilineTextAlignment(.leading)
                                    .padding(.top, 10)
                            }
                        }
                        Spacer()
                        NetworkImage(
                            viewModel: .init(url: "\(Configuration.host)/challange/group/getImage/\(model.id)/",
                                             store: store,
                                             placeholder: .init(named: "placeholder_image")),
                            size: .init(width: 80, height: 80)
                        )
                        Spacer()
                            .frame(width: 5)
                    }
                    .padding(20)
                }
                Spacer()
                    .frame(height: 27)
            }
            .frame(height: 157)
        }
    }

    private var progressView: some View {
        VStack {
            Spacer()
                .frame(height: progressTopInset)
            ZStack {
                Image(progressImageName)
                    .colorMultiply(Color(UIColor.CodeChallenge.gray2))
                if model.progress > 0 {
                    VStack(spacing: 0) {
                        Image(progressImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 14, height: (currentPeaceProgress ?? 0) + progressPreviousPeaceHeight, alignment: .top)
                            .clipped()
                            .colorMultiply(Color(UIColor.CodeChallenge.blue1))
                        if !(currentPeaceProgress == 134 || currentPeaceProgress == 108 || currentPeaceProgress == 104) {
                            Spacer()
                        }
                    }
                }
                VStack(spacing: 0) {
                    Image(progressImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 14, height: progressPreviousPeaceHeight > 0 ? progressPreviousPeaceHeight - 4 : 0, alignment: .top)
                        .clipped()
                        .colorMultiply(Color(UIColor.CodeChallenge.gray2))
                    Spacer()
                }
                if let previousPeaceProgress = previousPeaceProgress {
                    VStack(spacing: 0) {
                        Image(progressImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 14, height: previousPeaceProgress, alignment: .top)
                            .clipped()
                            .colorMultiply(Color(UIColor.CodeChallenge.blue1))
                        Spacer()
                    }
                }
            }
            Spacer()
                .frame(height: progressBottomInset)
        }
    }

    var completionView: some View {
        VStack {
            Spacer()
                .frame(height: completionViewTopInset)
            Image("home_progress_done")
                .resizable()
                .frame(width: 20, height: 20)
            Spacer()
        }
    }

    var completionViewTopInset: CGFloat {
        if previousModel != nil {
            return 19
        } else if nextModel != nil {
            return 18
        }
        return 20
    }

    var previousPeaceProgress: CGFloat? {
        guard let previousModel = previousModel else { return nil }
        //158 is total, 134 is visible in previous model
        let heightToCover = CGFloat(previousModel.progress)/100 * 158.0
        if heightToCover >= expectedHeight {
            return 20 - (158.0 - heightToCover)
        }
        return nil
    }

    var currentPeaceProgress: CGFloat? {
        if let _ = nextModel {
            let heightToCover = CGFloat(model.progress)/100 * 158.0
            if heightToCover >= expectedHeight {
                return expectedHeight
            }
            return heightToCover
        }
        return CGFloat(model.progress)/100 * expectedHeight
    }
}

fileprivate struct SkeletonView: View {
    let gridItemLayout = [GridItem(.flexible(), spacing: 0)]
    let model1 = ChallengeCollection(id: 1)
    let model2 = ChallengeCollection(id: 2)
    let model3 = ChallengeCollection(id: 3)
    let model4 = ChallengeCollection(id: 4)
    let model5 = ChallengeCollection(id: 5)

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: gridItemLayout,
                alignment: .leading,
                spacing: 0,
                pinnedViews: []) {
                    Section(
                        header:
                            Text("something")
                            .font(.h3)
                        .bold()
                        .padding(.leading, 10.0)
                        .padding(.bottom, 16)
                    ) {
                        HomeViewElementView(
                            model: model1, progressImageName: "home_progress_start",
                            progressTopInset: 21, progressBottomInset: 2,
                            progressPreviousPeaceHeight: 0, expectedHeight: 134,
                            previousModel: nil, nextModel: model2
                        )
                        HomeViewElementView(
                            model: model2, progressImageName: "home_progress_end",
                            progressTopInset: 2, progressBottomInset: 28,
                            progressPreviousPeaceHeight: 24, expectedHeight: 104,
                            previousModel: model1, nextModel: model3
                        )
                    }
                    Section(
                        header:
                            Text("something 2")
                            .font(.h3)
                        .bold()
                        .padding(.leading, 10.0)
                        .padding(.bottom, 16)
                    ) {
                        HomeViewElementView(
                            model: model4, progressImageName: "home_progress_only_section",
                            progressTopInset: 23, progressBottomInset: 26,
                            progressPreviousPeaceHeight: 0, expectedHeight: 108,
                            previousModel: nil, nextModel: model5
                        )
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
        }
        .padding(.top, 16)
        .redacted(reason: .placeholder)
    }
}
