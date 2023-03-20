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
    @State private var countdown = 4
    let data: ChallengeFriendData
    let onStart: () -> Void

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var challengeDetails: [ChallengeDetail] {
        return data.challenges.compactMap { store.state.challengeDetails[$0]?.value }
    }

    var account: Account? {
        return store.state.account.value
    }
    
    var body: some View {
        DoodledView {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 2)
                HStack {
                    Text("Competition 🎖️")
                        .multilineTextAlignment(.leading)
                        .font(.pageNameH1)
                        .foregroundColor(.white)
                }
                competingUsersView
                    .frame(height: 130)
                Group {
                    Text("You'll have 5 minutes to complete each of the challenges below")
                        .font(.h5)
                        .foregroundColor(.white)
                    Text("Starting in ... \(countdown)")
                        .foregroundColor(.white)
                        .font(.h4)
                        .transition(.scale(scale: 1.1))
                }
                .opacity(textAnimating ? 1 : 0)
                ForEach(Array(displayChallenges.enumerated()), id: \.offset) { (offset, challenge) in
                    itemView(challenge)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(UIColor.CodeChallenge.blue1))
                                .background(.CodeChallenge.dark)
                        )
                        .transition(.move(edge: .bottom))
                }
                Spacer()
            }
            .padding(20)
        }
        .onAppear {
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
            data.challenges.forEach { id in
                store.dispatch(LoadChallengeDetails(id: id))
            }
        }
        .onChange(of: challengeDetails.count) { newValue in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if newValue == data.challenges.count {
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
