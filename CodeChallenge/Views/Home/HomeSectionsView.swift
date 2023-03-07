//
//  HomeSectionsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/03/2023.
//

import Foundation
import SwiftUI
import UIKit
import Paywall

struct HomeSectionsView: View, HomeSectionsViewProps {
    @EnvironmentObject var store: Store
    let gridItemLayout = [GridItem(.flexible(), spacing: 0)]
    let humanLanguage: String
    let onCollectionTap: ((ChallengeCollection) -> Void)?

    var body: some View {
        sectionsView
    }

    private var sectionsView: some View {
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
                                    onCollectionTap?(collection)
                                }
                        }
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
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
