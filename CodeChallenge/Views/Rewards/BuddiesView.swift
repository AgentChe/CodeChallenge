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

struct BuddiesView: View {
    enum AlertInfo {
        case nonSufficientXP
        case confirmReward(Reward)
        case error
    }
    let onShowAlert: (AlertInfo) -> Void
    let onShowSuccess: (Reward) -> Void
    @EnvironmentObject var store: Store
    @State private var selection = 0
    @State private var shareText: ShareText? = nil
    @State private var branchURLString: String? = nil
    @State private var showShareSheet = false
    @State private var selectedReward: Reward?

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
                    if let selectedReward = selectedReward {
                        onShowSuccess(selectedReward)
                    }
                    selectedReward = nil
                }
        }
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 10) {
            if rewards.isEmpty {
                inviteFriendsView
            } else {
                SegmentedControlView(
                    selection: $selection,
                    sections: ["Invite Friend", "Rewards Store"],
                    onValueChange: { selection in
                        self.selection = selection
                    })
                .padding(.horizontal, 9)
                .frame(height: 31)

                switch selection {
                case 0:
                    inviteFriendsView
                case 1:
                    rewardsView
                default: EmptyView()
                }
            }

            Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var inviteFriendsView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Image("invite_friends")
                        .padding(.top, 30)
                        .padding(.leading, 9)
                    Spacer()
                }
                Text("Invite Friends, Earn XPs, and Redeem Rewards.")
                    .font(.semibold(size: 30))
                    .padding(.top, 35)
                Text("Invite your friends and earn 100 XPs for each successful referral. These XPs can be traded for hundreds of dollars worth of exciting rewards. Terms may apply.")
                    .font(.regular(size: 14))
                Text("Here's Your Invite Link")
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
                            UIPasteboard.general.string = branchURLString ?? ""
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
                Spacer()
            }
        }
    }

    @ViewBuilder
    private var rewardsView: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                alignment: .center,
                spacing: 16,
                pinnedViews: []) {
                    ForEach(rewards, id: \.id) { reward in
                        rewardView(reward)
                    }
                }
                .padding(4)
        }
        .padding(.top, 40)
    }

    func rewardView(_ reward: Reward) -> some View {
        VStack(alignment: .center, spacing: 8) {
            NetworkImage(
                viewModel: .init(url: reward.imageURL,
                                 store: store,
                                 placeholder: .init(named: "placeholder_image")),
                size: .init(width: .screenWidth/4, height: .screenWidth/4),
                contentMode: .fit
            )
            Text(reward.title)
                .font(.regular(size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text(reward.description)
                .font(.regular(size: 10))
                .foregroundColor(.white.withAlphaComponent(0.7))
                .multilineTextAlignment(.center)

            HStack {
                Spacer()
                if loadingReward != nil {
                    ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                } else {
                    Text("Redeem (\(reward.xp) XP)")
                        .font(.regular(size: 12))
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                }
                Spacer()
            }
            .frame(height: 28)
            .background {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.CodeChallenge.blue1))
            }
            .padding(.top, 2)
        }
        .padding(16)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedReward = reward
                if (account?.xp ?? 0) < reward.xp {
                    onShowAlert(.nonSufficientXP)
                } else {
                    onShowAlert(.confirmReward(reward))
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 13)
                    .stroke(Color(.CodeChallenge.dustyBlue), lineWidth: 2)
            }
    }
}
