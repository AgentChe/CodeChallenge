//
//  LeaderboardCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation
import UIKit
import SwiftUI

class LeaderboardCoordinator {
    let navigationController = UINavigationController()
    let store: Store

    init(store: Store) {
        self.store = store

        let leaderboardView = LeaderboardView()
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
}
