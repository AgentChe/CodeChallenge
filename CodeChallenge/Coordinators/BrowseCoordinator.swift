//
//  BrowseCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation
import UIKit
import SwiftUI

class BrowseCoordinator {
    let navigationController = UINavigationController()
    let store: Store
    var popupController: PopupViewController?
    var onGoPremium: (() -> Void)?

    init(store: Store) {
        self.store = store
        let browseView = BrowseView(onSearch: { [weak self] text in
            let view = BrowsedChallengesView(query: text, onEnterDetails: { [weak self] challenge in
                self?.openChallengeView(challenge: challenge, collection: nil, from: self?.navigationController)
            })
                .environmentObject(store)
            let controller = UIHostingController(rootView: view)
            self?.navigationController.pushViewController(controller, animated: true)
        }, onOpenChallenge: { [weak self] challenge in
            self?.openChallengeView(challenge: challenge, collection: nil, from: self?.navigationController)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: browseView)
        let tabBarItem = UITabBarItem(
            title: "Browse",
            image: UIImage(named: "searchTabIcon"),
            selectedImage: UIImage(named: "searchTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
        for language in ProgrammingLanguage.allCases {
            store.dispatch(LoadHashtags(programmingLanguage: language))
        }
    }
}

extension BrowseCoordinator: CodeChallengePresentable {}
