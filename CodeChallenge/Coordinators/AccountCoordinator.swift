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
    private var popupController: PopupViewController?

    init(store: Store) {
        self.store = store
        let accountView = AccountView(onLogin: { [weak self] in
            self?.onLogin?()
        }, onOpenSettings: { [weak self] in
            let view = SettingsView(onNotificationsTap: {
//                let view = NotificationsView()
//                    .environmentObject(store)
//                let controller = UIHostingController(rootView: view)
//                self?.navigationController.pushViewController(controller, animated: true)
                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }, onOpenUrl: { [weak self] url in
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
            self?.openCodeChallenge(challenge: challenge)
        }, onOpenCompletedChallenges: { [weak self] in
            let controller = UIHostingController(rootView: CompletedChallengesView(onEnterDetails: { [weak self] challenge in
                self?.openCodeChallenge(challenge: challenge)
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

    func openCodeChallenge(challenge: Challenge) {
        let challengeView = CodeChallengeView(codeChallenge: challenge, group: nil) { [weak self] challengeDetail in
            guard let challengeDetail = challengeDetail else { return }
            self?.showSolution(challengeDetail: challengeDetail, challenge: challenge)
        } onSuccess: { [weak self] challenge in
            guard let challenge = challenge else { return }
            self?.runSuccessPopup(challenge: challenge)
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

    private func showSolution(challengeDetail: ChallengeDetail, challenge: Challenge) {
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
        view.translatesAutoresizingMaskIntoConstraints = false
        if let rootController = UIApplication.shared.windows.first?.rootViewController {
            popupController?.present(from: rootController, bottomOffset: 0)
        }
    }
}
