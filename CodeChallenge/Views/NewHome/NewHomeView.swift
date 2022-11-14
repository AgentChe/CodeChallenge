//
//  NewHomeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/11/2022.
//

import Foundation
import SwiftUI
import UIKit

struct NewHomeView: View, NewHomeViewProps {
    let gridItemLayout = [GridItem(.flexible(), spacing: 0)]
    @EnvironmentObject var store: Store
    let language: String
    let humanLanguage: String
    let onCollectionTap: ((NewChallengeCollection, NewChallengeSection) -> Void)?
    @State private var displayXp: Int = 0

    @State private var displaySections: [NewChallengeSection] = []

    var body: some View {
        DoodledView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Code Challenges")
                    .font(.systemFont(ofSize: 30, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 16)
                    .padding(.leading, 16)
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: gridItemLayout,
                        alignment: .leading,
                        spacing: 0,
                        pinnedViews: []) {
                            ForEach(Array(displaySections.enumerated()), id: \.offset) { (sectionOffset, section) in
                                Section(
                                    header:
                                        Text(section.name)
                                        .font(.systemFont(ofSize: 18, weight: .semibold))
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
        }
        .onAppear {
            store.dispatch(LoadHomeSections(language: language, humanLanguage: humanLanguage))
            displaySections = sections ?? []
        }
        .onChange(of: sections) { newValue in
            displaySections = newValue ?? []
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                XPView(
                    xpText: "\(displayXp)",
                    backgroundColor: .CodeChallenge.dark,
                    xpIconColor: "white",
                    strokeColor: .CodeChallenge.blue1
                )
            }
        }
        .onChange(of: xp) { newValue in
            displayXp = xp
        }
        .onAppear {
            displayXp = xp
        }
    }

    private func homeViewElementView(offset: Int, sectionOffset: Int, section: NewChallengeSection, collection: NewChallengeCollection) -> some View {
        NewHomeViewElementView(model: collection,
                               progressImageName: progressImageName(index: offset, sectionIndex: sectionOffset),
                               progressTopInset: progressTopInset(index: offset, sectionIndex: sectionOffset),
                               progressBottomInset: progressBottomInset(index: offset, sectionIndex: sectionOffset),
                               progressPreviousPeaceHeight: progressPreviousPeaceHeight(index: offset, sectionIndex: sectionOffset),
                               expectedHeight: expectedHeight(index: offset, sectionIndex: sectionOffset),
                               previousModel: section.collections.element(at: offset - 1),
                               nextModel: section.collections.element(at: offset + 1))
    }
}

struct NewHomeViewElementView: View {
    let model: NewChallengeCollection
    let progressImageName: String
    let progressTopInset: CGFloat
    let progressBottomInset: CGFloat
    let progressPreviousPeaceHeight: CGFloat
    let expectedHeight: CGFloat

    let previousModel: NewChallengeCollection?
    let nextModel: NewChallengeCollection?

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
                        VStack(alignment: .leading, spacing: 10) {
                            Text(model.name)
                                .font(.systemFont(ofSize: 18, weight: .medium))
                                .multilineTextAlignment(.leading)
                            Text(model.description)
                                .font(.systemFont(ofSize: 12))
                                .foregroundColor(Color(UIColor.white.withAlphaComponent(0.6)))
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Image("test1")
                            .resizable()
                            .frame(width: 80, height: 80)
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
            return 24 - (158.0 - heightToCover)
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
