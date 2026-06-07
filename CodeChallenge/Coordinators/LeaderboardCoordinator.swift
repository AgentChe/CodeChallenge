//
//  LeaderboardCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class LeaderboardCoordinator {
    let navigationController = UINavigationController()
    let store: Store
    var challengeFriendNavigationController: UINavigationController?
    private var ongoingChallengeFriendDataCancellable: AnyCancellable?

    init(store: Store) {
        self.store = store

        let leaderboardView = LeaderboardView(onShareAndStart: { [weak self] in
            self?.onShareAndStart()
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: leaderboardView)
        let tabBarItem = UITabBarItem(
            title: "Leaderboard",
            image: UIImage(named: "leaderboardTabIcon")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "leaderboardTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
    }

    private func onShareAndStart() {
        ongoingChallengeFriendDataCancellable = store
            .statePublisher
            .compactMap { $0.ongoingChallengeFriendData.value }
            .sink(receiveValue: { [weak self] data in
                self?.ongoingChallengeFriendDataCancellable?.cancel()
                self?.ongoingChallengeFriendDataCancellable = nil
            })
    }
}

extension LeaderboardCoordinator: ChallengeFriendPresentable {}
