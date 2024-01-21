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
    var onClaimCertificate: ((Bool) -> Void)?
    var popupController: PopupViewController?
    var premiumPopupController: PopupViewController?
    var premiumViewController: UIViewController?

    init(store: Store) {
        self.store = store
        store.dispatch(GetLearnSections(programmingLanguage: .python))
        let learnView = LearnTabView { [weak self] element in
            self?.openLessonView(element: element)
        } onJumpSection: { [weak self] section in
            guard let self = self else { return }
            self.openChallengesView(for: section)
        } onOpenPremium: { [weak self] in
            guard let self = self else { return }
            store.dispatch(TrackAnalyticsEvent(event: AnalyticsEvent.goPremiumClicked))
        } onClaimCertificate: { [weak self] loggedIn in
            self?.onClaimCertificate?(loggedIn)
        }
            .environmentObject(store)
        let controller = UIHostingController(rootView: learnView)
        let tabBarItem = UITabBarItem(
            title: "Learn",
            image: UIImage(named: "practiceTabIcon"),
            selectedImage: UIImage(named: "practiceTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
    }

    private func openLessonView(element: LearnElement) {
        let controller = UIHostingController(rootView: LessonCollectionView(learnElement: element).environmentObject(store))
        controller.modalPresentationStyle = .fullScreen
        navigationController.present(controller, animated: true)
    }

    private func openChallengesView(for section: LearnSection) {
        let controller = UIHostingController(rootView: JumpHereContentsView(lessonCollection: section.lessonCollection).environmentObject(store))
        controller.modalPresentationStyle = .fullScreen
        navigationController.present(controller, animated: true)
    }
}
