//
//  HomeGroupView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 02/08/2022.
//

import Foundation
import SwiftUI

struct HomeGroupView: View {
    @EnvironmentObject var store: Store
    let challengeGroup: ChallengeGroup
    let onChallengeTap: ((Challenge, ChallengeGroup?) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(challengeGroup.name)
                .font(.systemFont(ofSize: 18, weight: .semibold))
                .foregroundColor(.CodeChallenge.white)
                .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Spacer()
                        .frame(width: 0)
                    ForEach(Array(challengeGroup.challenges.enumerated()), id: \.offset) { (index, challenge) in
                        switch challengeGroup.style {
                        case .large:
                            largeChallengeView(challenge: challenge, large: true)
                        case .medium:
                            largeChallengeView(challenge: challenge, large: false)
                        case .collection:
                            Text("")
                        }
                    }
                    Spacer()
                        .frame(width: 0)
                }
            }
        }
    }

    private func largeChallengeView(challenge: Challenge, large: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.CodeChallenge.background))
                .frame(width: large ? 200 : 130, height: 145)
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: large ? 15 : 10)
                    HStack {
                        NetworkImage(
                            viewModel: .init(url: "\(Configuration.host)/challange/getImage/\(challenge.challangeId)/",
                                             store: store,
                                             placeholder: .init(named: "placeholder_image")),
                            size: .init(width: 50, height: 50)
                        )
                        Spacer()
                        VStack {
                            if challenge.isPremium {
                                Image("challenge_premium_icon")
                            } else {
                                Button("\(challenge.xp)XP") {}
                                    .buttonStyle(RoundedButtonStyle(foregroundColor: .white, backgroundColor: .CodeChallenge.background, strokeColor: .white))
                                    .disabled(true)
                            }
                            Spacer()
                        }
                    }
                    .frame(height: large ? 50 : 40)
                    .padding(.horizontal, large ? 20 : 10)
                    VStack(alignment: .leading) {
                        Text(challenge.name)
                            .foregroundColor(.CodeChallenge.white)
                            .font(.systemFont(ofSize: large ? 16 : 14, weight: .semibold))
                            .lineLimit(large ? 2 : 3)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, large ? 20 : 10)

                Spacer()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(challenge.allTags, id: \.self) {
                            Button($0.name) {}
                                .buttonStyle(RoundedButtonStyle(foregroundColor: .white, backgroundColor: UIColor(hexString: "#\($0.color.components(separatedBy: "#").last ?? "")")))
                        }
                    }
                    .frame(height: 18)
                }
                        .padding(.horizontal, large ? 20 : 10)
                        .frame(height: 18)
                Spacer()
                    .frame(height: 10)
            }
            .frame(width: large ? 200 : 130, height: 150)
        }
        .onTapGesture {
            store.dispatch(TrackAnalyticsEvent(event: .challengeSelected(challenge, challengeGroup, "Home")))
            onChallengeTap?(challenge, challengeGroup)
        }
    }
}
