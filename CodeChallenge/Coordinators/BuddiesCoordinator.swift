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
        }, onShowSuccess: { [weak self] reward in
            self?.runSuccessPopup(for: reward)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: view)
        let tabBarItem = UITabBarItem(
            title: "Rewards",
            image: UIImage(named: "communityTabIcon"),
            selectedImage: UIImage(named: "communityTabIcon")
        )
        controller.tabBarItem = tabBarItem
        tabBarItem.badgeValue = "●"
        tabBarItem.badgeColor = .clear
        tabBarItem.setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
        navigationController.setViewControllers([controller], animated: false)
    }

    private func showAlert(with alertInfo: BuddiesView.AlertInfo) {
        switch alertInfo {
        case .nonSufficientXP:
            let alertController = UIAlertController(title: "Not enough XPs", message: "Sorry, you need more XP to claim this reward. Keep earning to get there!", preferredStyle: .alert)
            alertController.addAction(.init(title: "OK", style: .default))
            navigationController.present(alertController, animated: true)
        case .error:
            let alertController = UIAlertController(title: "Something went wrong", message: "Oops, it looks like we ran into a problem redeeming your XPs for the reward. Please try again.", preferredStyle: .alert)
            alertController.addAction(.init(title: "OK", style: .default))
            navigationController.present(alertController, animated: true)
        case .confirmReward(let reward):
            let alertController = UIAlertController(title: "Redeem \(reward.xp) XPs", message: "By redeeming \(reward.xp) XP reward, \(reward.xp) XPs will be deducted from your account. Do you want to proceed?", preferredStyle: .alert)
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

    private func runSuccessPopup(for reward: Reward) {
        let content = CelebrationView.Content(
            title: reward.title,
            description: "Your reward has been redeemed and will be delivered to your email within 72 hours.",
            imageURL: reward.imageURL,
            rewardText: nil
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
