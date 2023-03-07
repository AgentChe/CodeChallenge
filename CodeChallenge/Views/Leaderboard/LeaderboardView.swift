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
                    ForEach(Array(topUsers.enumerated()), id: \.offset) { (index, item) in
                        itemView(item, position: index + 1, medalPossible: true)
                            .padding(.horizontal, 16)
                    }
                    if !neightborUsers.isEmpty {
                        HStack {
                            Spacer()
                            Text("•  •  •")
                                .padding(.vertical, 20)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    ForEach(Array(neightborUsers.enumerated()), id: \.offset) { (index, item) in
                        itemView(item, position: index + 1, medalPossible: false)
                            .padding(.horizontal, 16)
                    }

                    Spacer()
                        .frame(height: 20)
                }
            }
        }
    }

    private func itemView(_ user: LeaderboardUser, position: Int, medalPossible: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.CodeChallenge.gray2).opacity(0.4))
            if user.id == account?.id {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.CodeChallenge.blue1), lineWidth: 1.5)
            }
            HStack(spacing: 10) {
                if medalPossible && position < 4 {
                    Image("medal_\(position)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28)
                }

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
                }
                Text(user.username ?? "Guest user")
                    .lineLimit(1)
                    .font(.semibold(size: 16))
                Spacer()
                HStack {
                    Text("\(user.xp)")
                    Image("xpIcon_white")
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .foregroundColor(.white)
            .frame(width: .screenWidth - 32)
        }
    }
}
