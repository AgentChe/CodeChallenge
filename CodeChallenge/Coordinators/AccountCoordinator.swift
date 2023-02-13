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
    var onLogin: (() -> Void)?
    var onGoPremium: (() -> Void)?
    var popupController: PopupViewController?

    init(store: Store) {
        self.store = store
        let accountView = AccountView(onLogin: { [weak self] in
            self?.onLogin?()
        }, onOpenSettings: { [weak self] in
            let view = SettingsView(onNotificationsTap: {
                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }, onOpenUrl: { url in
                guard let urll = URL(string: url) else { return }
                if UIApplication.shared.canOpenURL(urll) {
                    UIApplication.shared.open(urll)
                }
            }, onLogout: { [weak self] in
                self?.navigationController.popViewController(animated: true)
            })
                .environmentObject(store)
            let controller = UIHostingController(rootView: view)
            self?.navigationController.pushViewController(controller, animated: true)
        }, onOpenChallengeDetails: { [weak self] challenge in
            self?.openChallengeView(challenge: challenge, collection: nil, from: self?.navigationController)
        }, onOpenCompletedChallenges: { [weak self] in
            let controller = UIHostingController(rootView: CompletedChallengesView(onEnterDetails: { [weak self] challenge in
                self?.openChallengeView(challenge: challenge, collection: nil, from: self?.navigationController)
            }).environmentObject(store))
            self?.navigationController.pushViewController(controller, animated: true)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: accountView)
        navigationController.setViewControllers([controller], animated: false)

        store.statePublisher
            .map { $0.account.value?.isPremium }
            .ephemeralSink { [weak self] isPremium in
                guard let self = self else { return }
                if isPremium == false {
                    let tabBarItem = UITabBarItem(
                        title: "Account",
                        image: UIImage(named: "accountTabIcon")?.withRenderingMode(.alwaysOriginal),
                        selectedImage: UIImage(named: "accountTabIcon")
                    )
                    self.navigationController.viewControllers.first?.tabBarItem = tabBarItem
                } else {
                    let tabBarItem = UITabBarItem(
                        title: "Account",
                        image: UIImage(named: "accountTabIcon")?.withRenderingMode(.alwaysOriginal),
                        selectedImage: UIImage(named: "accountTabIcon_premium_selected")?.withRenderingMode(.alwaysOriginal)
                    )
                    tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.CodeChallenge.purple], for: .selected)
                    self.navigationController.viewControllers.first?.tabBarItem = tabBarItem
                }
            }
    }
}

extension AccountCoordinator: CodeChallengePresentable {}
