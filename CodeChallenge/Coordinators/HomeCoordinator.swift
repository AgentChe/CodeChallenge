//
//  HomeCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation
import UIKit
import SwiftUI

class HomeCoordinator {
    let navigationController = UINavigationController()
    let store: Store

    init(store: Store) {
        self.store = store
        let homeView = HomeView(onChallengeTap: { [weak self] challenge in
            self?.openCodeChallenge(challenge: challenge)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: homeView)
        let tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "homeTabIcon"),
            selectedImage: UIImage(named: "homeTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
    }

    func openCodeChallenge(challenge: Challenge) {
        let challengeView = CodeChallengeView(codeChallenge: challenge)
        let controller = UIHostingController(rootView: challengeView)
        navigationController.pushViewController(controller, animated: true)
    }
}
