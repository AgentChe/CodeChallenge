//
//  LeaderboardView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/03/2023.
//

import Foundation
import SwiftUI

struct LeaderboardView: View, LeaderboardViewProps {
    @EnvironmentObject var store: Store

    var body: some View {
        DoodledView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("Leaderboard")
                        .font(.pageNameH1)
                        .foregroundColor(.white)
                        .padding(.bottom, 16)
                        .padding(.leading, 16)
                    ForEach(topUsers, id: \.id) { item in
                        itemView(item, medalPossible: true)
                            .padding(.horizontal, 16)
                    }
                    if !neightborUsers.isEmpty {
                        HStack {
                            Spacer()
                            Text("•  •  •")
                                .padding(.vertical, 20)
                                .foregroundColor(.CodeChallenge.white.withAlphaComponent(0.8))
                            Spacer()
                        }
                    }
                    ForEach(Array(neightborUsers.enumerated()), id: \.offset) { (index, item) in
                        itemView(item, medalPossible: false)
                            .padding(.horizontal, 16)
                    }

                    Spacer()
                        .frame(height: 20)
                }
            }
        }
    }

    private func itemView(_ user: LeaderboardUser, medalPossible: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.CodeChallenge.gray2).opacity(0.4))
            if user.id == account?.id {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.CodeChallenge.blue1), lineWidth: 1.5)
            }
            HStack(spacing: 4) {
                Text("\(user.position)")
                    .font(.smallText)
                    .padding(.leading, 8)
                    .foregroundColor(.CodeChallenge.white.withAlphaComponent(0.8))
                ZStack {
                    NetworkImage(
                        viewModel: .init(url: "\(Configuration.host)/user/getImage/\(user.id)/",
                                         store: store,
                                         placeholder: .init(named: "placeholder_image"),
                                         showsPlaceholderInitially: true,
                                         cacheEnabled: false),
                        animated: false,
                        size: .init(width: 50, height: 50)
                    )
                    .cornerRadius(25)
                    if user.isPremium {
                        Image("premium_image_background_bold")
                            .resizable()
                            .frame(width: 57, height: 57)
                    }
                    if medalPossible && user.position < 4 {
                        Image("medal_\(user.position)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 34)
                            .padding(.top, 32)
                            .padding(.leading, 36)
                    }
                }
                .frame(width: 70)
                Text(user.username ?? "Guest user")
                    .lineLimit(1)
                    .font(.semibold(size: 16))
                    .padding(.vertical, 30)
                Spacer()
                HStack {
                    Text("\(user.xp)")
                    Image("xpIcon_white")
                }
            }
            .padding(.horizontal, 10)
            .foregroundColor(.white)
            .frame(width: .screenWidth - 32)
        }
    }
}
