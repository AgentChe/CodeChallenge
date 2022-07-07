//
//  AccountCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import SwiftUI

class AccountCoordinator {
    let navigationController = UINavigationController()
    let store: Store

    init(store: Store) {
        self.store = store
        let accountView = AccountView()
            .environmentObject(store)
        let controller = UIHostingController(rootView: accountView)
        let tabBarItem = UITabBarItem(
            title: "Account",
            image: UIImage(named: "homeTabIcon"),
            selectedImage: UIImage(named: "homeTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
    }
}
