//
//  ChallengeFriendContentsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 18/03/2023.
//

import Foundation
import SwiftUI

struct ChallengeFriendContentsView: View {
    @EnvironmentObject var store: Store
    @State private var displayChallenges: [ChallengeDetail] = []
    @State private var isAnimating = false
    @State private var textAnimating = false
    @State private var countdown = 11
    let data: ChallengeFriendData
    let onStart: () -> Void
    let onSkip: () -> Void

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var challengeDetails: [ChallengeDetail] {
        return data.challenges.compactMap { store.state.challengeDetails[$0]?.value }
    }

    var account: Account? {
        return store.state.account.value
    }
    
    var body: some View {
        DoodledView {
            VStack(spacing: 32) {
                ZStack {
                    Text("Competition 🏆")
                        .font(.pageNameH1)
                        .foregroundColor(.white)
                    HStack {
                        Spacer()
                        Button("Skip") {
                            store.dispatch(Action.updateOngoingChallengeFriendData(.pending))
                            onSkip()
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.top, UIDevice.hasDisplayNotch ? 40 : 20)
                Spacer()
                    .frame(height: 20)
                competingUsersView
                    .frame(height: 130)
                Group {
                    Text("You'll have 5 minutes to complete \n each of the challenges below")
                        .font(.h4)
                        .foregroundColor(.white)
                        .opacity(isAnimating ? 1 : 0)
                    Text("Starting in \(countdown)")
                        .foregroundColor(.white)
                        .font(.h3)
                        .opacity(textAnimating ? 1 : 0)
                }
                VStack(spacing: 12) {
                    ForEach(Array(displayChallenges.enumerated()), id: \.offset) { (offset, challenge) in
                        itemView(challenge)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(UIColor.CodeChallenge.blue1))
                                    .background(.CodeChallenge.dark)
                            )
                            .transition(.move(edge: .bottom))
                    }
                }
                Spacer()
            }
            .padding(20)
        }
        .navigationBarHidden(true)
        .onAppear {
            data.challenges.forEach { id in
                store.dispatch(LoadChallengeDetailsAndResetProgress(id: id, programmingLanguage: data.codehubProgrammingLanguage))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        textAnimating = true
                    }
                }
            }
        }
        .onChange(of: challengeDetails) { _ in
            loadDisplayChallenges(count: challengeDetails.count)
        }
        .onReceive(timer) { _ in
            if countdown == 0 {
                timer.upstream.connect().cancel()
                onStart()
            } else {
                withAnimation {
                    countdown = countdown - 1
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }

    private func loadDisplayChallenges(count: Int) {
        if count == data.challenges.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                for index in 0..<data.challenges.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.5 * Double(index))) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            let newItem = challengeDetails[index]
                            displayChallenges.append(newItem)
                        }
                    }
                }
            }
        }
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
            }
            .opacity(isAnimating ? 1 : 0)
        }
    }

    private func itemView(_ challengeDetail: ChallengeDetail) -> some View {
        HStack(spacing: 10) {
            VStack {
                Spacer()
                NetworkImage(
                    viewModel: .init(url: "\(Configuration.host)/challange/getImage/\(challengeDetail.id)/",
                                     store: store,
                                     placeholder: .init(named: "placeholder_image")),
                    size: .init(width: 35, height: 35)
                )
                Spacer()
            }
            Text(challengeDetail.name)
                .lineLimit(2)
                .foregroundColor(.white)
                .font(.bodyText)
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(height: 60)
    }
}
