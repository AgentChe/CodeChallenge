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
    private var popupController: PopupViewController?

    init(store: Store) {
        self.store = store
        let instanceId = UUID()
        let instanceId2 = UUID()
        let browseView = BrowseView(onSearch: { [weak self] text in
            let view = BrowsedChallengesView(query: text, onEnterDetails: { [weak self] challenge in
                self?.openChallengeView(challenge: challenge)
            })
                .environmentObject(store)
                .environment(\.instanceID, instanceId)
            let controller = UIHostingController(rootView: view)
            self?.navigationController.pushViewController(controller, animated: true)
            self?.store.dispatch(LoadSearchResults(instanceId: instanceId))
        }, onOpenChallenge: { [weak self] challenge in
            self?.openChallengeView(challenge: challenge)
        })
            .environmentObject(store)
            .environment(\.instanceID, instanceId)
        let controller = UIHostingController(rootView: browseView)
        let tabBarItem = UITabBarItem(
            title: "Browse",
            image: UIImage(named: "searchTabIcon"),
            selectedImage: UIImage(named: "searchTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
        store.dispatch(LoadHashtags(instanceID: instanceId, programmingLanguage: .python))
        store.dispatch(LoadHashtags(instanceID: instanceId2, programmingLanguage: .java))
    }

    func openChallengeView(challenge: Challenge) {
        let challengeView = CodeChallengeView(codeChallenge: challenge, group: nil) { [weak self] challengeDetail in
            guard let challengeDetail = challengeDetail else { return }
            self?.showSolution(challengeDetail: challengeDetail, challenge: challenge)
        } onSuccess: { [weak self] challenge in
            guard let challenge = challenge else { return }
            self?.runSuccessPopup(challenge: challenge)
        } onDismiss: { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
            .environmentObject(store)
        let controller = UIHostingController(rootView: challengeView)
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: true)
    }

    private func showSolution(challengeDetail: ChallengeDetail, challenge: Challenge) {
        store.dispatch(TrackAnalyticsEvent(event: .solutionOpened(challenge, nil)))
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
        view.translatesAutoresizingMaskIntoConstraints = false
        if let rootController = UIApplication.shared.windows.first?.rootViewController {
            popupController?.present(from: rootController, bottomOffset: 0)
        }
    }
}
