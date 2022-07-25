//
//  HomeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation
import SwiftUI

struct HomeView: View, HomeViewProps {
    enum Component {
        case challengesGroup(ChallengeGroup)
        case premium
    }
    @EnvironmentObject var store: Store
    let onChallengeTap: ((Challenge) -> Void)?
    
    var body: some View {
        DoodledView {
            if let homeViewComponents = homeViewComponents {
                contentView(homeViewComponents)
            } else {
                Text("Loading...")
            }
        }
        .background(.clear)
        .onAppear {
            store.dispatch(LoadChallengeGroups())

            // FIXME: delete
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let first = challengeGroups?.first?.challenges.first {
                    onChallengeTap?(first)
                }
            }
        }
    }

    func contentView(_ homeViewComponents: [HomeView.Component]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Code Challenge")
                    .font(.systemFont(ofSize: 30, weight: .semibold))
                    .foregroundColor(.CodeChallenge.white)
                    .padding(.horizontal, 20)
                ForEach(Array(homeViewComponents.enumerated()), id: \.offset) {
                    switch $0.1 {
                    case .premium:
                        premiumView
                    case .challengesGroup(let group):
                        groupView(group)
                    }
                }
            }
        }
    }

    func groupView(_ challengeGroup: ChallengeGroup) -> some View {
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
                        VStack(alignment: .leading) {
                            ZStack {
//                                NetworkImage(
//                                    viewModel: .init(url: challenge.icon, store: store),
//                                    size: .init(width: 100, height: 100)
//                                )
                                Image(challenge.icon)
                                    .frame(width: 100, height: 100)
                                .cornerRadius(10)
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                            .frame(width: 6)
                                        Button(challenge.level) {}
                                            .buttonStyle(RoundedButtonStyle())
                                            .disabled(true)
                                        Spacer()
                                    }
                                    Spacer()
                                        .frame(height: 6)
                                }
                            }
                            .frame(height: 100)
                            Text(challenge.name)
                                .foregroundColor(.CodeChallenge.white)
                                .font(.systemFont(ofSize: 14, weight: .semibold))
                                .lineLimit(2)
                            Text(challenge.tagsDescription)
                                .foregroundColor(.CodeChallenge.blue1)
                                .font(.systemFont(ofSize: 10))
                                .lineLimit(1)
                            Spacer()
                        }
                        .frame(width: 100)
                        .onTapGesture {
                            onChallengeTap?(challenge)
                        }
                    }
                }
            }
        }
    }

    private var premiumView: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.CodeChallenge.gray1))
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                    .frame(height: 0)
                Text("Get Premium")
                    .font(.systemFont(ofSize: 18, weight: .semibold))
                    .padding(.horizontal, 20)
                Text("You're crushing your goals. Come crush our challenges!!!! 🤣")
                    .font(.systemFont(ofSize: 14))
                    .padding(.horizontal, 20)
                ZStack {
                    Rectangle()
                        .frame(height: 38)
                        .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                        .background(.CodeChallenge.blue1)
                        .opacity(0.3)
                    HStack {
                        Text("Get Premium")
                            .font(.systemFont(ofSize: 12, weight: .semibold))
                            .padding(.leading, 15)
                        Spacer()
                    }
                }
            }
            .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
    }
}

fileprivate struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            configuration.label
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .font(.systemFont(ofSize: 10))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .frame(height: 15)
                        .foregroundColor(Color.white)
                        .opacity(0.3)
                )
        }
    }
}
