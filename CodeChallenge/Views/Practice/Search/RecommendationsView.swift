//
//  RecommendationsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 21/11/2022.
//

import Foundation
import SwiftUI

struct RecommendationsView: View, RecommendationsViewProps {
    @EnvironmentObject var store: Store
    let onChallengeTap: ((Challenge) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended for You")
                .font(.h4)
                .foregroundColor(.CodeChallenge.white)
                .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Spacer()
                        .frame(width: 0)
                    ForEach(Array(challenges.enumerated()), id: \.offset) { (_, challenge) in
                        if challenge.isPremium == true && getProgress(challenge: challenge) == "done" {
                            itemView(challenge: challenge, progress: getProgress(challenge: challenge))
                                .frame(width: (UIScreen.main.bounds.width - 20)/2)
                                .onTapGesture {
                                    onChallengeTap?(challenge)
                                }
                                .modifier(PremiumGradientModifier(changeStrokeColor: true, cornerRadius: 13, strokeWidth: 1.5))
                        } else {
                            itemView(challenge: challenge, progress: getProgress(challenge: challenge))
                                .frame(width: (UIScreen.main.bounds.width - 20)/2)
                                .onTapGesture {
                                    onChallengeTap?(challenge)
                                }.background(
                                    RoundedRectangle(cornerRadius: 13)
                                        .stroke(Color(getProgress(challenge: challenge) != "todo" ? (getProgress(challenge: challenge) == "done" ? .CodeChallenge.blue1 : .CodeChallenge.white) : .CodeChallenge.gray1),
                                                lineWidth: 1.5
                                        )
                                )
                        }
                    }
                    Spacer()
                        .frame(width: 0)
                }
            }
        }
    }

    private func itemView(challenge: Challenge, progress: String?) -> some View {
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
                    if challenge.progress == "done" && challenge.isPremium == false {
                        Image("challenge_progress_done")
                    } else if challenge.isPremium {
                        if challenge.progress == "done" {
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
        .padding(1)
    }
}

