//
//  PremiumCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation
import UIKit
import SwiftUI

class PremiumCoordinator {
    let navigationController = UINavigationController()
    let store: Store

    init(store: Store) {
        self.store = store
        let premiumView = PremiumView()
            .environmentObject(store)
        let controller = UIHostingController(rootView: premiumView)
        let tabBarItem = UITabBarItem(
            title: "Premium",
            image: UIImage(named: "homeTabIcon"),
            selectedImage: UIImage(named: "homeTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
    }
}
