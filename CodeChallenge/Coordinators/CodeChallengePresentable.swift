//
//  CodeChallengePresentable.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 10/02/2023.
//

import Foundation
import SwiftUI

protocol CodeChallengePresentable: AnyObject {
    var store: Store { get }
    var onGoPremium: (() -> Void)? { get }
    var popupController: PopupViewController? { get set }
}

extension CodeChallengePresentable {
    func openChallengeView(
        challenge: Challenge,
        collection: ChallengeCollection?,
        from navigationController: UINavigationController?) {
            guard let navigationController = navigationController else { return }
        let challengeView = CodeChallengeView(codeChallenge: challenge) { [weak self] challengeDetail in
            guard let challengeDetail = challengeDetail else { return }
            self?.showSolution(challengeDetail: challengeDetail, challenge: challenge)
        } onSuccess: { [weak self] challenge in
            guard let challenge = challenge else { return }
            self?.runSuccessPopup(challenge: challenge, from: navigationController)
            if let collection = collection {
                self?.store.dispatch(LoadCollectionContent(collection: collection))
            }
        } onDismiss: {
            navigationController.popViewController(animated: true)
        } onGoPremium: { [weak self] in
            navigationController.popViewController(animated: true)
            self?.onGoPremium?()
        } onOpenChat: { [weak self] in
            self?.openChat(navigationController: navigationController)
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
        if let rootController = UIApplication.shared.mainWindow?.rootViewController {
            popupController?.present(from: rootController, bottomOffset: 0)
        }
    }

    private func openChat(navigationController: UINavigationController) {
        let view = ChatAIView()
            .environmentObject(store)
        let controller = UIHostingController(rootView: view)
        controller.modalPresentationStyle = .overFullScreen
        navigationController.present(controller, animated: true)
    }

    private func runSuccessPopup(challenge: ChallengeDetail, from navigationController: UINavigationController?) {
        let content = CelebrationView.Content(
            title: "\(challenge.name) is solved!",
            description: "The only time you should ever look back is to see how far you've come. Just continue practicing!",
            imageURL: "\(Configuration.host)/challange/getImage/\(challenge.id)/",
            rewardText: "+\(challenge.xp)"
        )
        let view = CelebrationView(content: content, store: store)
        view.onDismiss = { [weak self] in
            self?.popupController?.hide()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                navigationController?.popViewController(animated: true)
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
