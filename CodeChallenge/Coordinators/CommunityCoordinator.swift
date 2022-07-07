//
//  CommunityCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation
import UIKit
import SwiftUI

class CommunityCoordinator {
    let navigationController = UINavigationController()
    let store: Store

    init(store: Store) {
        self.store = store
        let communityView = CommunityView()
            .environmentObject(store)
        let controller = UIHostingController(rootView: communityView)
        let tabBarItem = UITabBarItem(
            title: "Community",
            image: UIImage(named: "homeTabIcon"),
            selectedImage: UIImage(named: "homeTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
    }
}
