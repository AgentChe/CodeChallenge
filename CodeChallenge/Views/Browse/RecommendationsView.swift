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
                        itemView(challenge: challenge)
                    }
                    Spacer()
                        .frame(width: 0)
                }
            }
        }
    }

    private func itemView(challenge: Challenge) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.CodeChallenge.background))
                .frame(width: 200)
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height:15)
                    HStack {
                        NetworkImage(
                            viewModel: .init(url: "\(Configuration.host)/challange/getImage/\(challenge.id)/",
                                             store: store,
                                             placeholder: .init(named: "placeholder_image")),
                            size: .init(width: 50, height: 50)
                        )
                        Spacer()
                        VStack {
                            if challenge.progress == "done" {
                                Image("challenge_progress_done")
                            } else if challenge.isNew {
                                NewLabelView()
                            }  else if challenge.isPremium {
                                Image("challenge_premium_icon")
                            } else {
                                ChallengeXPView(xpText: "\(challenge.xp)")
                            }
                            Spacer()
                        }
                    }
                    .frame(height: 50)
                    .padding(.horizontal, 20)
                    VStack(alignment: .leading) {
                        Text(challenge.name)
                            .foregroundColor(.CodeChallenge.white)
                            .font(.h5)
                            .lineLimit(2)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 20)

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
                        .padding(.horizontal, 20)
                        .frame(height: 18)
                Spacer()
                    .frame(height: 10)
            }
            .frame(width: 200, height: 150)
        }
        .onTapGesture {
            store.dispatch(TrackAnalyticsEvent(event: .challengeSelected(challenge, nil, "Browse")))
            onChallengeTap?(challenge)
        }
    }
}

struct RoundedButtonStyle: ButtonStyle {
    let foregroundColor: UIColor
    let backgroundColor: UIColor
    var strokeColor: UIColor? = nil

    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            configuration.label
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .font(.tag)
                .background(
                    Group {
                        if let strokeColor = strokeColor {
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color(
                                    red: strokeColor.rgba.red,
                                    green: strokeColor.rgba.green,
                                    blue: strokeColor.rgba.blue
                                ), lineWidth: 1)
                                .frame(height: 18)
                        } else {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(
                                    red: backgroundColor.rgba.red,
                                    green: backgroundColor.rgba.green,
                                    blue: backgroundColor.rgba.blue
                                ))
                                .frame(height: 18)
                        }
                    }
                )
                .foregroundColor(foregroundColor)
        }
    }
}
