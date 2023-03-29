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

                Text(description)
                    .font(.h4)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)

                Spacer()

                Button("Okay") {
                    store.dispatch(Action.updateOngoingChallengeFriendData(.pending))
                    onContinue()
                }
                .buttonStyle(PrimaryButton())
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
                Text("Friend")
                Text(oponentScore != -1 ? "\(oponentScore ?? 0)" : "-")
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

    var userScore: Int {
        result.filter { $0.1 }.count
    }

    var oponentScore: Int? {
        return challengeFriendData?.fromUser == account?.id ? challengeFriendData?.scores.toUser : challengeFriendData?.scores.fromUser
    }

    var won: Bool? {
        guard let oponentScore = oponentScore, oponentScore != -1 else { return nil }
        return userScore > oponentScore
    }

    var draw: Bool? {
        guard let oponentScore = oponentScore, oponentScore != -1 else { return nil }
        return userScore == oponentScore
    }

    var lost: Bool? {
        guard let oponentScore = oponentScore, oponentScore != -1 else { return nil }
        return userScore < oponentScore
    }

    var title: String {
        guard let oponentScore = oponentScore, oponentScore != -1 else {
            return "Waiting for opponent"
        }
        if userScore > oponentScore {
            return "You won"
        }

        if userScore == oponentScore {
            return "Its a draw"
        }

        if userScore < oponentScore {
            return "You lost"
        }

        return ""
    }

    var description: String {
        guard let oponentScore = oponentScore, oponentScore != -1 else {
            return "You're done! Let's wait for the friend to complete. We will notify you upon having the result."
        }

        if userScore > oponentScore {
            return "You've won, and we have special surprise for you - 50 xps ⚡️"
        }

        if userScore == oponentScore {
            return "Its a draw! Let's practice more to beat everyone up 🥊"
        }

        if userScore < oponentScore {
            return "You've lost! But you know what? This is the reason we keep on developing the app - to give you more and help you more!"
        }

        return ""
    }
}
