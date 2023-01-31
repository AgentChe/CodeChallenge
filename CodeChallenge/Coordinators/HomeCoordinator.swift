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
    private var popupController: PopupViewController?

    init(store: Store) {
        self.store = store
        let homeView = NewHomeView(humanLanguage: "en") { [weak self] collection, section in
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

    private func openCollectionDetail(collection: NewChallengeCollection, section: NewChallengeSection) {
        let view = NewCollectionContentView(collection: collection, section: section, onChallengeOpen: { [weak self] challenge in
            self?.openCodeChallenge(challenge: challenge, group: nil, collection: collection)
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

    func openCodeChallenge(challenge: Challenge, group: ChallengeGroup?, collection: NewChallengeCollection?) {
        let challengeView = CodeChallengeView(codeChallenge: challenge, group: group) { [weak self] challengeDetail in
            guard let challengeDetail = challengeDetail else { return }
            self?.showSolution(challengeDetail: challengeDetail, challenge: challenge, group: group)
        } onSuccess: { [weak self] challenge in
            guard let challenge = challenge else { return }
            self?.runSuccessPopup(challenge: challenge)
            if let collection = collection {
                self?.store.dispatch(LoadCollectionContent(collection: collection))
            }
        } onDismiss: { [weak self] in
            self?.navigationController.popViewController(animated: true)
        } onGoPremium: { [weak self] in
            self?.navigationController.popViewController(animated: true)
            self?.onGoPremium?()
        }
            .environmentObject(store)
        let controller = UIHostingController(rootView: challengeView)
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: true)
    }

    private func showSolution(challengeDetail: ChallengeDetail, challenge: Challenge, group: ChallengeGroup?) {
        store.dispatch(TrackAnalyticsEvent(event: .solutionOpened(challenge, store.state.programmingLanguage)))
        let view = SolutionView(solution: challengeDetail.solutionCode.code?.removingPercentEncoding ?? "")
        view.onDismiss = { [weak self] in
            self?.popupController?.hide()
        }
        popupController = PopupViewController(contentView: view)
        view.translatesAutoresizingMaskIntoConstraints = false
        if let rootController = UIApplication.shared.windows.first?.rootViewController {
            popupController?.present(from: rootController, bottomOffset: 0)
        }
    }

    private func runSuccessPopup(challenge: ChallengeDetail) {
        let view = CelebrationView(challenge: challenge, store: store)
        view.onDismiss = { [weak self] in
            self?.popupController?.hide()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self?.navigationController.popViewController(animated: true)
            }
        }
        popupController = PopupViewController(contentView: view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            view.translatesAutoresizingMaskIntoConstraints = false
            if let rootController = UIApplication.shared.windows.first?.rootViewController {
                self?.popupController?.present(from: rootController, bottomOffset: 0)
            }
        }
    }
}
