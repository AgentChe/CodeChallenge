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
        case collection([ChallengeGroup])
        case premium
    }
    @EnvironmentObject var store: Store
    let onChallengeTap: ((Challenge, ChallengeGroup?) -> Void)?
    let onCollectionTap: (ChallengeGroup) -> Void
    let onSearch: (String) -> Void
    @State private var displayHomeViewComponents: [HomeView.Component] = []
    
    var body: some View {
        DoodledView {
            if let homeViewComponents = displayHomeViewComponents, !homeViewComponents.isEmpty {
                contentView(homeViewComponents)
            } else {
                SkeletonHomeView()
            }
        }
        .onChange(of: challengeGroups) { _ in
            displayHomeViewComponents = homeViewComponents
        }
        .background(.clear)
    }

    func contentView(_ homeViewComponents: [HomeView.Component]) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                Text("Code Challenges")
                    .font(.systemFont(ofSize: 30, weight: .semibold))
                    .foregroundColor(.CodeChallenge.white)
                    .padding(.horizontal, 20)
                ForEach(Array(homeViewComponents.enumerated()), id: \.offset) {
                    switch $0.1 {
                    case .premium:
                        premiumView
                    case .challengesGroup(let group):
                        HomeGroupView(challengeGroup: group, onChallengeTap: onChallengeTap)
                    case .collection(let collections):
                        HomeCollectionView(collections: collections, onChallengeTap: onChallengeTap, onCollectionTap: onCollectionTap)
                    }
                }

                Spacer()
                    .frame(height: 20)
            }
        }
    }

    private var premiumView: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.CodeChallenge.background))
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
                    RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 10)
                        .fill(Color(.CodeChallenge.blue1))
                        .frame(height: 38)
                    HStack {
                        Text("Get Premium")
                            .font(.systemFont(ofSize: 14, weight: .regular))
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

struct RoundedButtonStyle: ButtonStyle {
    let foregroundColor: UIColor
    let backgroundColor: UIColor
    var strokeColor: UIColor? = nil

    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            configuration.label
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .font(.systemFont(ofSize: 10))
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

struct SkeletonHomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Code Challenges")
                .font(.systemFont(ofSize: 30, weight: .semibold))
                .foregroundColor(.CodeChallenge.white)
                .padding(.horizontal, 20)
            VStack(alignment: .leading, spacing: 8) {
                Text("New Challenges")
                    .font(.systemFont(ofSize: 18, weight: .semibold))
                    .foregroundColor(.CodeChallenge.white)
                    .padding(.horizontal, 20)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        Spacer()
                            .frame(width: 0)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.CodeChallenge.background))
                            .frame(width: 200, height: 145)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.CodeChallenge.background))
                            .frame(width: 200, height: 145)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.CodeChallenge.background))
                            .frame(width: 200, height: 145)
                    }
                }
            }
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.CodeChallenge.background))
                .frame(height: 162)
                .padding(.horizontal, 20)
            Spacer()
        }
        .redacted(reason: .placeholder)
    }
}
