//
//  RootCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine

final class RootCoordinator {
    private let window: UIWindow
    private let store = Store()
    private let loginCoordinator: LoginCoordinator
    private let accountCoordinator: AccountCoordinator
    private let homeCoordinator: HomeCoordinator
    private let browseCoordinator: BrowseCoordinator
    private let communityCoordinator: CommunityCoordinator
    private let premiumCoordinator: PremiumCoordinator

    private let tabBarController = UITabBarController()
    private var authCancellable: AnyCancellable?
    private var logoutCancellable: AnyCancellable?

    init(window: UIWindow) {
        self.window = window
        loginCoordinator = LoginCoordinator(store: store)
        accountCoordinator = AccountCoordinator(store: store)
        homeCoordinator = HomeCoordinator(store: store)
        browseCoordinator = BrowseCoordinator(store: store)
        communityCoordinator = CommunityCoordinator(store: store)
        premiumCoordinator = PremiumCoordinator(store: store)
        setupAppAppearance()
    }

    func start() {
        store.dispatch(GuestAuth())
        let tabs = [
            homeCoordinator.navigationController,
            accountCoordinator.navigationController,
            browseCoordinator.navigationController,
            communityCoordinator.navigationController,
            premiumCoordinator.navigationController
        ]
        tabBarController.setViewControllers(tabs, animated: false)
        tabBarController.tabBar.items?.forEach {
            $0.image = $0.image?.withRenderingMode(.alwaysOriginal)
            $0.selectedImage = $0.selectedImage?.withRenderingMode(.alwaysOriginal)
        }
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        window.rootViewController = tabBarController
    }

    private func showLogin() {
        window.rootViewController = loginCoordinator.navigationController
        loginCoordinator.start()

        authCancellable = self.store
            .statePublisher
            .map { $0.user.value?.username != nil }
            .removeDuplicates()
            .sink { [weak self] isLoggedIn in
                guard let self = self else { return }
                if isLoggedIn {
                    self.window.rootViewController = self.accountCoordinator.navigationController
//                    self.accountCoordinator.start()
                }
            }

        logoutCancellable = self.store
            .statePublisher
            .map { $0.user.isPending }
            .removeDuplicates()
            .sink { [weak self] isLoggedOut in
                guard let self = self else { return }
                if isLoggedOut {
                    self.window.rootViewController = self.loginCoordinator.navigationController
                    self.loginCoordinator.start()
                }
            }
    }
}

extension RootCoordinator {
    private func setupAppAppearance() {
        window.backgroundColor = .CodeChallenge.dark
        window.overrideUserInterfaceStyle = .light

        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.backgroundColor = .CodeChallenge.dark
        tabBarAppearance.barTintColor = .CodeChallenge.dark
        tabBarAppearance.isOpaque = false
        tabBarAppearance.itemPositioning = .centered
        tabBarAppearance.itemSpacing = 1

        let backImage = UIImage(named: "navbar_back")
        let barAppearance = UINavigationBarAppearance()
        barAppearance.titlePositionAdjustment = .init(horizontal: 0, vertical: 4)
        barAppearance.configureWithTransparentBackground()
        barAppearance.backgroundImage = .init()
        barAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        barAppearance.backButtonAppearance.normal.backgroundImage = backImage
        barAppearance.backButtonAppearance.normal.accessibilityLabel = "navigation back"
        barAppearance.backgroundColor = .clear
        barAppearance.shadowColor = UIColor.clear
        barAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.CodeChallenge.white,
                                                  .font: UIFont.systemFont(ofSize: 48)]
        barAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.CodeChallenge.white,
            .font: UIFont.systemFont(ofSize: 32)
        ]
        UINavigationBar.appearance().compactAppearance = barAppearance
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        UINavigationBar.appearance().tintColor = .clear
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().isOpaque = false
    }
}
