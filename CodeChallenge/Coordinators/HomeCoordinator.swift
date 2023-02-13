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
    var onboardingNavigationController: UINavigationController?
    let store: Store
    var onGoPremium: (() -> Void)?
    var popupController: PopupViewController?

    init(store: Store) {
        self.store = store
        let homeView = HomeView(humanLanguage: "en") { [weak self] collection, section in
            self?.openCollectionDetail(collection: collection, section: section)
        }
            .environmentObject(store)
        let controller = UIHostingController(rootView: homeView)
        let tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "homeTabIcon"),
            selectedImage: UIImage(named: "homeTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)

        DispatchQueue.main.async { [weak self] in
            self?.presentGetStartedIfNecessary()
        }
    }

    private func openCollectionDetail(collection: ChallengeCollection, section: ChallengeSection) {
        let view = CollectionContentView(collection: collection, section: section, onChallengeOpen: { [weak self] challenge in
            self?.openChallengeView(challenge: challenge, collection: collection, from: self?.navigationController)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: view)
        navigationController.pushViewController(controller, animated: true)
    }

    private func presentGetStartedIfNecessary() {
        guard !UserDefaults.standard.bool(forKey: "getStartedPresented") else { return }
        UserDefaults.standard.set(true, forKey: "getStartedPresented")
        let view = GetStartedView { [weak self] in
            self?.presentProgrammingLanguagesView()
        }
            .environmentObject(store)
        let controller = UIHostingController(rootView: view)
        onboardingNavigationController = UINavigationController(rootViewController: controller)
        onboardingNavigationController?.modalPresentationStyle = .fullScreen
        if let onboardingNavigationController = onboardingNavigationController {
            navigationController.present(onboardingNavigationController, animated: false)
        }
    }

    private func presentProgrammingLanguagesView() {
        let view = OnboardingLanguagesView { [weak self] in
            self?.onboardingNavigationController?.dismiss(animated: true)
        }
            .environmentObject(store)
        let controller = UIHostingController(rootView: view)
        onboardingNavigationController?.pushViewController(controller, animated: true)
    }
}

extension HomeCoordinator: CodeChallengePresentable {}
