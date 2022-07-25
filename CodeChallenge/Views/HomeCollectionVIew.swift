//
//  HomeCollectionVIew.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 02/08/2022.
//

import Foundation
import SwiftUI

struct HomeCollectionView: View {
    @EnvironmentObject var store: Store
    let collections: [ChallengeGroup]
    let onChallengeTap: ((Challenge, ChallengeGroup) -> Void)?
    let onCollectionTap: (ChallengeGroup) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                Spacer()
                    .frame(width: 10)
                ForEach(Array(collections.enumerated()), id:\.offset) { _, element in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.CodeChallenge.background))
                            .cornerRadius(12)
                        VStack {
                            ZStack {
                                Rectangle()
                                    .fill(Color(.CodeChallenge.dark))
                                RoundedCornersShape(corners: [.topLeft, .topRight], radius: 12)
                                    .fill(Color(.CodeChallenge.purple))
                                    .padding(.top, 17)
                                HStack {
                                    Text(element.name.removingPercentEncoding ?? element.name)
                                        .lineLimit(1)
                                        .padding(.top, 17)
                                        .foregroundColor(.white)
                                        .font(.systemFont(ofSize: 18, weight: .semibold))
                                    Spacer()
                                    NetworkImage(
                                        viewModel: .init(url: "\(Configuration.host)/challange/group/getImage/\(element.id ?? "")/",
                                                         store: store,
                                                         placeholder: .init(named: "placeholder_image")),
                                        size: .init(width: 74, height: 74)
                                    )
                                        .padding(.bottom, 6)
                                }
                                .padding(.horizontal, 20)
                                .frame(height: 62)
                        }
                            .frame(height: 79)
                            .padding(.bottom, 10)

                            VStack(spacing: 0) {
                                HStack {
                                    Text(element.description.removingPercentEncoding ?? element.description)
                                        .foregroundColor(.white)
                                        .font(.systemFont(ofSize: 14))
                                        .lineLimit(2)
                                        .padding(.bottom, 15)
                                    Spacer()
                                }
                                ForEach(Array(element.challenges[0...2].enumerated()), id: \.offset) { _, element in
                                    smallChallengeView(challenge: element)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 25)
                        }
                        .frame(width: UIDevice.hasSmallScreen ? 260 : 325, height: 385)
                    }
                    .frame(width: UIDevice.hasSmallScreen ? 260 : 325, height: 385)
                    .onTapGesture {
                        onCollectionTap(element)
                    }
                }
                Spacer()
                    .frame(width: 10)
            }
        }
    }

    private func smallChallengeView(challenge: Challenge) -> some View {
        VStack(spacing: 0) {
            Divider()
                .frame(height: 1)
                .background(.CodeChallenge.purple)
            HStack(alignment: .top) {
                NetworkImage(
                    viewModel: .init(url: "\(Configuration.host)/challange/getImage/\(challenge.challangeId)/",
                                     store: store,
                                     placeholder: .init(named: "placeholder_image")),
                    size: .init(width: 41, height: 41)
                )
                Spacer()
                    .frame(width: 10)
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        Text(challenge.name)
                            .lineLimit(1)
                            .font(.systemFont(ofSize: 14))
                            .foregroundColor(.white)
                        Spacer()
                        if challenge.isPremium {
                            Image("challenge_premium_icon")
                                .padding(.bottom, 15)
                        } else {
                            Button("\(challenge.xp)XP") {}
                                .buttonStyle(RoundedButtonStyle(foregroundColor: .white, backgroundColor: .CodeChallenge.background, strokeColor: .white))
                                .disabled(true)
                                .padding(.bottom, 15)
                        }
                    }
                    HStack {
                        Spacer()
                        ForEach(Array(challenge.allTags.prefix(3)), id: \.self) {
                            Button($0.name) {}
                                .buttonStyle(RoundedButtonStyle(foregroundColor: .white, backgroundColor: UIColor(hexString: "#\($0.color.components(separatedBy: "#").last ?? "")")))
                        }
                    }
                }
            }
            .padding(.top, 15)
        }
        .frame(height: 76)
    }
}
