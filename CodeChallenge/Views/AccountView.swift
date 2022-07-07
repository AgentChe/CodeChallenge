//
//  AccountView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import SwiftUI

struct AccountView: View, AccountViewProps {
    @EnvironmentObject var store: Store

    var body: some View {
        DoodledView {
            if let account = account {
                content(account: account)
            }
        }
        .onAppear {
            store.dispatch(LoadAccount())
        }
    }

    private func content(account: Account) -> some View {
        ScrollView {
            VStack {
                Image("imSer")
                    .frame(width: 120, height: 120)
                    .cornerRadius(60)
                Text(account.name)
                    .foregroundColor(.white)
                    .font(.boldSystemFont(ofSize: 25))
                Text("@\(account.username)")
                    .foregroundColor(.white)
                    .font(.systemFont(ofSize: 14))
                HStack(spacing: 50) {
                    VStack {
                        Text("\(account.solvedChallenges)")
                            .font(.systemFont(ofSize: 18))
                        Text("Challenges")
                            .font(.systemFont(ofSize: 14))
                    }
                    VStack {
                        Text("\(account.followersCount)")
                            .font(.systemFont(ofSize: 18))
                        Text("Followers")
                            .font(.systemFont(ofSize: 14))
                    }
                    VStack {
                        Text("\(account.followingsCount)")
                            .font(.systemFont(ofSize: 18))
                        Text("Following")
                            .font(.systemFont(ofSize: 14))
                    }
                }
                .foregroundColor(.white)
                .padding(.top, 30)
                .padding(.bottom, 25)

                streakView(account: account)
            }
        }
        .background(.clear)
    }

    private func streakView(account: Account) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.CodeChallenge.gray1))
            VStack(alignment: .leading, spacing: 0) {
                Text("You're on a")
                    .font(.systemFont(ofSize: 16))
                Text("\(account.streak)-day streak")
                    .font(.boldSystemFont(ofSize: 30))
                    .padding(.bottom, 30)
                HStack(spacing: (.screenWidth - 50)/7 - 30) {
                    ForEach(account.streaktoKeyValueTuple(), id: \.self) { item in
                        ZStack {
                            if item.value {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.CodeChallenge.blue1))
                                    .frame(width: 30, height: 30)
                            } else {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(.CodeChallenge.blue1), lineWidth: 1)
                                    .frame(width: 30, height: 30)
                            }

                            Text(item.key)
                                .foregroundColor(item.value ? .CodeChallenge.white : .CodeChallenge.blue1)
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
            .padding(20)
            .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
    }
}
