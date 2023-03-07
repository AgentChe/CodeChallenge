//
//  NewCollectionContentView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/11/2022.
//

import Foundation
import SwiftUI

struct CollectionContentView: View, CollectionContentViewProps {
    let gridItemLayout = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    @EnvironmentObject var store: Store
    let collection: ChallengeCollection
    let section: ChallengeSection
    let onChallengeOpen: (Challenge) -> Void
    let onConceptReview: (SectionConceptReview) -> Void
    @State private var displayContent: ChallengeCollectionContent?
    @State private var displayChallenges: [Challenge] = []
    @State private var displayConceptReview: Bool = false

    var body: some View {
        DoodledView {
            if let displayContent = displayContent {
                content(displayContent: displayContent)
            } else {
                SkeletonView()
            }
        }
        .onAppear {
            if displayChallenges.isEmpty {
                store.dispatch(LoadCollectionContent(collection: collection))
                displayContent = content
                if let content = content {
                    for index in 0..<content.challenges.count {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.05 * Double(index))) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                let newItem = content.challenges[index]
                                displayChallenges.append(newItem)
                            }
                        }
                    }
                }
            }
            if let conceptReview = section.conceptReview, !showConceptReview {
                store.dispatch(FetchConceptReview(sectionConceptReview: conceptReview))
            } else {
                displayConceptReview = showConceptReview
            }
        }
        .onChange(of: content) { newValue in
            guard let newValue = newValue else { return }
            displayChallenges = newValue.challenges
            displayContent = newValue
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                DefaultXPView(
                    xpText: "\(xp)",
                    backgroundColor: .CodeChallenge.dark,
                    xpIconColor: "white",
                    strokeColor: .CodeChallenge.blue1
                )
            }
        }
        .onChange(of: showConceptReview) { newValue in
            displayConceptReview = newValue
        }
    }

    func content(displayContent: ChallengeCollectionContent) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(displayContent.name)
                .font(.h2)
                .foregroundColor(.white)
            Text(displayContent.description)
                .font(.bodyText)
                .foregroundColor(UIColor.white.withAlphaComponent(0.6))
            if displayConceptReview {
                Button("Try the Cheatsheets") {
                    store.dispatch(TrackAnalyticsEvent(event: .conceptOpened(displayContent.name)))
                    if let conceptReview = section.conceptReview {
                        onConceptReview(conceptReview)
                    }
                }
                .buttonStyle(ReviewTheConceptButton())
                .clipShape(Capsule())
            }
            progressBar(displayContent: displayContent)
                .padding(.top, 16)
            ScrollView(showsIndicators: false) {
                LazyVGrid(
                    columns: gridItemLayout,
                    alignment: .center,
                    spacing: 16,
                    pinnedViews: []) {
                        ForEach(displayChallenges, id: \.id) { challenge in
                            challengeView(for: challenge)
                        }
                    }
            }
            .padding(.top, 3)
        }
        .padding(.horizontal, 16)
    }

    func progressBar(displayContent: ChallengeCollectionContent) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color(UIColor.CodeChallenge.gray2))
                .frame(height: 3)
            HStack {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color(UIColor.CodeChallenge.blue1))
                    .frame(width: (.screenWidth - 32) * CGFloat(displayContent.progress)/100, height: 3)
                if displayContent.progress != 100 {
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    func challengeView(for challenge: Challenge) -> some View {
        if challenge.isPremium == true && getProgress(challenge: challenge) == "done" {
            challengeView(challenge: challenge, progress: getProgress(challenge: challenge))
                .transition(.move(edge: .bottom))
                .contentShape(Rectangle())
                .onTapGesture {
                    store.dispatch(TrackAnalyticsEvent(event: .challengeSelected(challenge, "Home", store.state.programmingLanguage)))
                    onChallengeOpen(challenge)
                }
                .modifier(PremiumGradientModifier(changeStrokeColor: true, cornerRadius: 13, strokeWidth: 1.5))
        } else {
            challengeView(challenge: challenge, progress: getProgress(challenge: challenge))
                .transition(.move(edge: .bottom))
                .contentShape(Rectangle())
                .onTapGesture {
                    store.dispatch(TrackAnalyticsEvent(event: .challengeSelected(challenge, "Home", store.state.programmingLanguage)))
                    onChallengeOpen(challenge)
                }
                .background {
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(Color(getProgress(challenge: challenge) != "todo" ? (getProgress(challenge: challenge) == "done" ? .CodeChallenge.blue1 : .CodeChallenge.white) : .CodeChallenge.gray1),
                                lineWidth: 1.5
                        )
                }
        }
    }

    func challengeView(challenge: Challenge, progress: String?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                NetworkImage(
                    viewModel: .init(url: "\(Configuration.host)/challange/getImage/\(challenge.id)/",
                                     store: store,
                                     placeholder: .init(named: "placeholder_image")),
                    size: .init(width: 45, height: 45)
                )
                Spacer()
                VStack {
                    if progress == "done" && challenge.isPremium == false {
                        Image("challenge_progress_done")
                    } else if challenge.isPremium {
                        if progress == "done" {
                            Image("premium_challenge_progress_done")
                        } else {
                            ChallengePremiumXPView(xpText: "\(challenge.xp)")
                        }
                    } else if challenge.isNew {
                        NewLabelView()
                    } else {
                        ChallengeDefaultXPView(xpText: "\(challenge.xp)")
                    }
                    Spacer()
                }
            }
            .frame(height: 45)
            VStack(alignment: .leading) {
                Text(challenge.name)
                    .foregroundColor(.CodeChallenge.white)
                    .font(.bodyText)
                    .lineLimit(2)
                Spacer()
            }
            .padding(.top, 15)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(challenge.allTags, id: \.self) {
                        Button($0.name) {}
                            .buttonStyle(RoundedButtonStyle(foregroundColor: .white, backgroundColor: UIColor(hexString: "#\($0.color.components(separatedBy: "#").last ?? "")")))
                    }
                }
                .frame(height: 18)
            }
            .frame(height: 18)
        }
        .padding(15)
        .frame(height: 157)
    }
}

fileprivate struct SkeletonView: View {
    let gridItemLayout = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("displayContent.name")
                .font(.systemFont(ofSize: 30, weight: .semibold))
                .foregroundColor(.white)
            Text("displayContent.description")
                .font(.systemFont(ofSize: 18, weight: .semibold))
                .foregroundColor(UIColor.white.withAlphaComponent(0.6))
            RoundedRectangle(cornerRadius: 1.5)
                .padding(.top, 16)
                .frame(height: 3)
            ScrollView {
                LazyVGrid(
                    columns: gridItemLayout,
                    alignment: .center,
                    spacing: 16,
                    pinnedViews: []) {
                        element
                        element
                        element
                    }
            }
            .padding(.top, 3)
        }
        .padding(.horizontal, 16)
        .redacted(reason: .placeholder)
    }

    var element: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13)
                .stroke(Color(.CodeChallenge.blue1), lineWidth: 1.5)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    RoundedRectangle(cornerRadius: 22.5)
                        .fill(Color(UIColor.CodeChallenge.darkBlue))
                        .frame(width: 45, height: 45)
                        .redacted(reason: .placeholder)
                    Spacer()
                    VStack {
                        Image("challenge_premium_icon")
                            .redacted(reason: .placeholder)
                        Spacer()
                    }
                }
                .frame(height: 45)
                VStack(alignment: .leading) {
                    Text("challenge.name")
                        .foregroundColor(.CodeChallenge.white)
                        .font(.bodyText)
                        .lineLimit(2)
                        .redacted(reason: .placeholder)
                    Spacer()
                }
                .padding(.top, 15)

                Spacer()
                .frame(height: 18)
            }
            .padding(15)
        }
        .frame(height: 157)
        .padding(1)
    }
}
