//
//  LearnCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 16/04/2023.
//

import Foundation
import UIKit
import SwiftUI

class LearnCoordinator {
    let navigationController = UINavigationController()

    let store: Store
    var onGoPremium: (() -> Void)?
    var popupController: PopupViewController?
    var premiumPopupController: PopupViewController?

    init(store: Store) {
        self.store = store
        let learnView = LearnTabView { [weak self] element in
            self?.openLessonView(element: element)
        } onOpenPremium: { [weak self] in
            guard let self = self else { return }
            self.presentPremiumScreen(from: self.navigationController)
        }
            .environmentObject(store)
        let controller = UIHostingController(rootView: learnView)
        let tabBarItem = UITabBarItem(
            title: "Learn",
            image: UIImage(named: "homeTabIcon"),
            selectedImage: UIImage(named: "homeTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
    }

    private func openLessonView(element: HomeElement) {
        let controller = UIHostingController(rootView: LessonCollectionView(homeElement: element).environmentObject(store))
        controller.modalPresentationStyle = .fullScreen
        navigationController.present(controller, animated: true)
    }
}

extension LearnCoordinator: PremiumPresentable {}
