//
//  ChallengeFriendResultView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/03/2023.
//

import Foundation
import SwiftUI

struct ChallengeFriendResultView: View {
    @EnvironmentObject var store: Store
    @State private var displayChallenges: [ChallengeDetail] = []
    @State private var isAnimating = false
    let result: [(Int, Bool)]
    let onContinue: () -> Void

    var body: some View {
        DoodledView {
            VStack(spacing: 32) {
                Text(title)
                    .font(.pageNameH1)
                    .foregroundColor(.white)
                    .padding(.top, UIDevice.hasDisplayNotch ? 40 : 20)
                Spacer()
                    .frame(height: 20)
                competingUsersView
                    .frame(height: 150)

                Spacer()

                Button("Continue") {
                    onContinue()
                }
                .buttonStyle(PrimaryButton())
                .animation(.none, value: UUID())
            }
            .padding(20)
        }
        .onAppear {
            store.dispatch(SendChallengeFriendScore(score: userScore))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isAnimating = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            store.dispatch(Action.updateOngoingChallengeFriendData(.pending))
        }
        .edgesIgnoringSafeArea(.top)
    }

    private var competingUsersView: some View {
        HStack {
            VStack {
                if let account = account {
                    NetworkImage(
                        viewModel: .init(url: account.imageUrl,
                                         store: store,
                                         placeholder: .init(named: "placeholder_image"),
                                         showsPlaceholderInitially: true,
                                         cacheEnabled: true),
                        animated: false,
                        size: .init(width: 100, height: 100)
                    )
                    .cornerRadius(50)
                    Text(account.username ?? "")
                    Text("\(userScore)")
                }
            }
            .opacity(isAnimating ? 1 : 0)

            Text("VS")
                .frame(width: isAnimating ? 40 : .screenWidth)
                .foregroundColor(.white)
                .font(.bodyText)
                .opacity(isAnimating ? 1 : 0)
            VStack {
                Image("friend_account")
                    .resizable()
                    .frame(width: 100, height: 100)
                .cornerRadius(50)
                Text("My Friend")
                Text(oponentScore != nil ? "\(oponentScore ?? 0)" : "Waiting ...")
            }
            .opacity(isAnimating ? 1 : 0)
        }
    }
}

extension ChallengeFriendResultView {
    var account: Account? {
        return store.state.account.value
    }

    var challengeFriendData: ChallengeFriendData? {
        store.state.ongoingChallengeFriendData.value
    }

    var won: Bool? {
        guard let fromUser = challengeFriendData?.scores.fromUser, fromUser != -1 else { return nil }
        return userScore > fromUser
    }

    var draw: Bool? {
        guard let fromUser = challengeFriendData?.scores.fromUser, fromUser != -1 else { return nil }
        return userScore == fromUser
    }

    var lost: Bool? {
        guard let fromUser = challengeFriendData?.scores.fromUser, fromUser != -1 else { return nil }
        return userScore < fromUser
    }

    var userScore: Int {
        result.filter { $0.1 }.count
    }

    var oponentScore: Int? {
        return (challengeFriendData?.fromUser == account?.id) ? challengeFriendData?.scores.toUser : challengeFriendData?.scores.fromUser
    }

    var title: String {
        if oponentScore == nil || oponentScore == -1 { return "Waiting for opponent"}
        return won == true ? "You won" : (draw == true ? "It's a draw" : "You lost")
    }
}
