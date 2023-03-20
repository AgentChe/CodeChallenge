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
import Branch

class LeaderboardCoordinator {
    let navigationController = UINavigationController()
    let store: Store
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
                self?.composeBranchLinkAndShare(data)
            })
    }

    private func composeBranchLinkAndShare(_ data: ChallengeFriendData) {
        let branchUniversalObject = BranchUniversalObject()
        branchUniversalObject.title = "Lets compete"
        branchUniversalObject.locallyIndex = false
        branchUniversalObject.imageUrl = "https://codehub.ninja/static/icon.jpg"
        let properties = BranchLinkProperties()
        properties.addControlParam("challengeFriendId", withValue: "\(data.id)")

        let urlString = branchUniversalObject.getShortUrl(with: properties) ?? ""

        let activityController = UIActivityViewController(activityItems: [urlString], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = navigationController.view
        activityController.completionWithItemsHandler = { [weak self] _, success, _, _ in
            guard success else { return }
//            self?.startCompetition(data)
        }
        navigationController.present(activityController, animated: true)
    }

//    private func startCompetition(_ data: ChallengeFriendData) {
//        let controller = UIHostingController(rootView: ChallengeFriendContentsView(data: data))
//        controller.modalPresentationStyle = .overFullScreen
//        navigationController.present(controller, animated: true)
//    }
}
