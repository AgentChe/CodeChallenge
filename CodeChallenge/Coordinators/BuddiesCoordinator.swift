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
    var onLogin: ((ThunkAction) -> Void)? = nil
    var popupController: PopupViewController? = nil

    init(store: Store) {
        self.store = store
        let view = BuddiesView(onShowAlert: { [weak self] alertInfo in
            self?.showAlert(with: alertInfo)
        }, onShowSuccess: { [weak self] in
            self?.runSuccessPopup()
        })
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

    private func showAlert(with alertInfo: BuddiesView.AlertInfo) {
        switch alertInfo {
        case .error:
            let alertController = UIAlertController(title: "We couldnt redeem ur xps for the gift card", message: nil, preferredStyle: .alert)
            alertController.addAction(.init(title: "OK", style: .default))
            navigationController.present(alertController, animated: true)
        case .confirmReward(let reward):
            let alertController = UIAlertController(title: "Are you sure you want to redeem 20 xps for this reward?", message: nil, preferredStyle: .alert)
            alertController.addAction(.init(title: "YES", style: .default, handler: { [weak self] _ in
                let action = SelectReward(reward: reward)
                if UserDefaults.standard.bool(forKey: "isLoggedIn") {
                    self?.store.dispatch(action)
                } else {
                    self?.onLogin?(action)
                }
            }))
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            navigationController.present(alertController, animated: true)
        }
    }

    private func runSuccessPopup() {
        let content = CelebrationView.Content(
            title: "You are special!",
            description: "We'll send you an email in 72 hours with ur gift card",
            imageURL: "https://oyster.ignimgs.com/mediawiki/apis.ign.com/pokemon-blue-version/8/89/Pikachu.jpg",
            rewardText: "Pikachu gift card"
        )
        let view = CelebrationView(content: content, store: store)
        view.onDismiss = { [weak self] in
            self?.popupController?.hide()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self?.navigationController.popViewController(animated: true)
            }
        }
        popupController = PopupViewController(contentView: view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            view.translatesAutoresizingMaskIntoConstraints = false
            if let rootController = UIApplication.shared.mainWindow?.rootViewController {
                self?.popupController?.present(from: rootController, bottomOffset: 0)
            }
        }
    }
}
