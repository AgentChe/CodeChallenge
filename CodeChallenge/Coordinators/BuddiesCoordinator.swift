//
//  BuddiesCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 24/10/2022.
//

import Foundation
import UIKit
import SwiftUI

class BuddiesCoordinator {
    let navigationController = UINavigationController()
    let store: Store

    init(store: Store) {
        self.store = store
        let view = BuddiesView()
            .environmentObject(store)
        let controller = UIHostingController(rootView: view)
        let tabBarItem = UITabBarItem(
            title: "Buddies",
            image: UIImage(named: "communityTabIcon"),
            selectedImage: UIImage(named: "communityTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
    }
}
