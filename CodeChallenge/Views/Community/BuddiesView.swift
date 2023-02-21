//
//  BuddiesView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 23/10/2022.
//

import Foundation
import SwiftUI
import UIKit
import Branch
import Combine

fileprivate struct ShareText: Identifiable {
    let id = UUID()
    let text: String
}

struct BuddiesView: View {
    enum AlertInfo {
        case confirmReward(Reward)
        case error
    }
    let onShowAlert: (AlertInfo) -> Void
    let onShowSuccess: () -> Void
    @EnvironmentObject var store: Store
    @State private var selection = 1
    @State private var shareText: ShareText? = nil
    @State private var branchURLString: String? = nil
    @State private var showShareSheet = false

    var account: Account? {
        return store.state.account.value
    }

    var rewards: [Reward] {
        store.state.rewards.value ?? []
    }

    var loadingReward: Reward? {
        store.state.loadingReward?.reward
    }

    var loadingRewardSuccess: Bool {
        store.state.loadingReward?.status.isSuccess == true
    }

    var errorPublisher: AnyPublisher<Bool, Never> {
        store.$state
            .map { $0.loadingReward?.status.error != nil }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var body: some View {
        DoodledView {
            content
                .sheet(item: $shareText) { item in
                    ActivityView(text: item.text)
                }
                .onAppear {
                    let branchUniversalObject = BranchUniversalObject()
                    branchUniversalObject.title = "Come learn coding with us!"
                    branchUniversalObject.locallyIndex = false
                    branchUniversalObject.imageUrl = "https://codehub.ninja/static/icon.jpg"
                    let properties = BranchLinkProperties()
                    properties.addControlParam("referringUserID", withValue: "\(account?.id ?? 0)")

                    branchURLString = branchUniversalObject.getShortUrl(with: properties) ?? ""
                }
                .onReceive(errorPublisher) { error in
                    if error {
                        onShowAlert(.error)
                    }
                }
                .onChange(of: loadingRewardSuccess) { newValue in
                    guard newValue else { return }
                    onShowSuccess()
                }
        }
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 10) {
            SegmentedControlView(
                selection: $selection,
                sections: ["Rewards Store", "Invite Friend"],
                onValueChange: { selection in
                self.selection = selection
            })
            .padding(.horizontal, 9)
            .frame(height: 31)

            switch selection {
            case 0:
                rewardsView
            case 1:
                inviteFriendsView
            default: EmptyView()
            }

            Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var inviteFriendsView: some View {
        HStack {
            Image("invite_friends")
                .padding(.top, 30)
                .padding(.leading, 9)
            Spacer()
        }
        Text("Invite Your friend. Study free for a year.")
            .font(.semibold(size: 30))
            .padding(.top, 35)
        Text("You will both get rewarded $10 when your friend places their first Instacart order. Terms apply")
            .font(.regular(size: 14))
        Text("Here's your invite link")
            .padding(.top, 30)
            .font(.semibold(size: 18))
            .padding(.bottom, 6)
        HStack(spacing: 10) {
            HStack {
                Text(branchURLString ?? "")
                    .font(.regular(size: 14))
                    .padding(16)
                Spacer()
                Button("Copy") {
                    UIPasteboard.general.string = "random"
                }
                .foregroundColor(.CodeChallenge.blue1)
                .padding(.trailing, 14)
                .font(.semibold(size: 18))
            }.background{
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(UIColor.CodeChallenge.dustyBlue), lineWidth: 1)
            }
            .frame(height: 46)

            Button {
                guard let branchURLString = branchURLString else { return }
                shareText = ShareText(text: branchURLString)
            } label: {
              Text("Share")
                    .padding(14)
                    .background(.CodeChallenge.blue1)
                    .font(.semibold(size: 18))
                    .cornerRadius(8)
                    .frame(height: 46)
            }
        }
    }

    @ViewBuilder
    private var rewardsView: some View {
        ForEach(rewards, id: \.name) { reward in
            if loadingReward?.name == reward.name {
                Text("Loading")
            } else {
                Button(reward.name) {
                    onShowAlert(.confirmReward(reward))
                }
            }
        }
    }
}
