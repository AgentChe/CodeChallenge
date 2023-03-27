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
    var challengeFriendNavigationController: UINavigationController?

    let store: Store
    var onGoPremium: (() -> Void)?
    var onEndingOnboarding: (() -> Void)?
    var popupController: PopupViewController?

    init(store: Store) {
        self.store = store
        let homeView = HomeView(humanLanguage: "en") { [weak self] (collection) in
            self?.openCollectionDetail(collection: collection)
        } onSearch: { [weak self] text in
            let view = BrowsedChallengesView(query: text, onEnterDetails: { [weak self] challenge in
                self?.openChallengeView(challenge: challenge, collection: nil, from: self?.navigationController)
            })
                .environmentObject(store)
            let controller = UIHostingController(rootView: view)
            self?.navigationController.pushViewController(controller, animated: true)
        } onOpenChallenge: { [weak self] challenge in
            self?.openChallengeView(challenge: challenge, collection: nil, from: self?.navigationController)
        } onOpenTryAIScreen: { [weak self] in
            self?.openTryAIView()
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

        for language in ProgrammingLanguage.allCases {
            store.dispatch(LoadHashtags(programmingLanguage: language))
        }
    }

    private func openTryAIView() {
        let view = TryAIView { [weak self] challenge in
            self?.openChallengeView(challenge: challenge, collection: nil, from: self?.navigationController)
        } goProductHunt: { string in
            if let appSettings = URL(string: string), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
            .environmentObject(store)

        let controller = UIHostingController(rootView: view)
        navigationController.present(controller, animated: true)
    }

    private func openCollectionDetail(collection: ChallengeCollection) {
        let view = CollectionContentView(collection: collection, onChallengeOpen: { [weak self] challenge in
            self?.openChallengeView(challenge: challenge, collection: collection, from: self?.navigationController)
        }, onConceptReview: { [weak self] conceptReview in
            self?.presentConceptReview(sectionConceptReview: conceptReview)
        }, onLessonOpen: { [weak self] collectionContent in
            guard let self = self else { return }
            self.openChat(mode: .explainTopic(collectionContent, self.store.state.programmingLanguage), navigationController: self.navigationController)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: view)
        navigationController.pushViewController(controller, animated: true)
    }

    private func presentGetStartedIfNecessary() {
        guard !UserDefaults.standard.bool(forKey: "getStartedPresented") else { return }
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
            UserDefaults.standard.set(true, forKey: "getStartedPresented")
            self?.onEndingOnboarding?()
        }
            .environmentObject(store)
        let controller = UIHostingController(rootView: view)
        onboardingNavigationController?.pushViewController(controller, animated: true)
    }

    private func presentConceptReview(sectionConceptReview: SectionConceptReview) {
        let view = LessonView(sectionConceptReview: sectionConceptReview)
            .environmentObject(store)
        let controller = UIHostingController(rootView: view)
        controller.modalPresentationStyle = .fullScreen
        navigationController.present(controller, animated: true)
    }
}

extension HomeCoordinator: CodeChallengePresentable {}
