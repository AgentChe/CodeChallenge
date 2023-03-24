//
//  ChallengeFriendPresentable.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 19/03/2023.
//

import Foundation
import UIKit
import SwiftUI

protocol ChallengeFriendPresentable: AnyObject {
    var store: Store { get }
    var challengeFriendNavigationController: UINavigationController? { get set }
}

extension ChallengeFriendPresentable {
    func startChallengeFriend(with data: ChallengeFriendData, from controller: UIViewController) {
        let result: [(Int, Bool)] = []
        let hostingController = UIHostingController(rootView: ChallengeFriendContentsView(data: data, onStart: { [weak self] in
            self?.flowThroughChallenges(challenges: data.challenges, result: result, completion: { [weak self] result in
                self?.showCompletionScreen(with: data, result: result)
            })
        }).environmentObject(store))
        hostingController.view.backgroundColor = .CodeChallenge.dark
        challengeFriendNavigationController = UINavigationController(rootViewController: hostingController)
        challengeFriendNavigationController?.modalPresentationStyle = .overFullScreen
        challengeFriendNavigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if let challengeFriendNavigationController = challengeFriendNavigationController {
            controller.present(challengeFriendNavigationController, animated: true)
        }
    }

    private func flowThroughChallenges(challenges: [Int], result: [(Int, Bool)], completion: @escaping ([(Int, Bool)]) -> Void) {
        guard let navigationController = challengeFriendNavigationController, let challengeId = (challenges.first { !result.map { $0.0 }.contains($0) }) else {
            completion(result)
            return
        }
        var newResult = result
        let challengeView = ChallengeFriendCodeChallengeView(codeChallengeId: challengeId, onContinue: { [weak self] solved in
            newResult.append((challengeId, solved))
            self?.flowThroughChallenges(challenges: challenges, result: newResult, completion: completion)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: challengeView)
        navigationController.pushViewController(controller, animated: true)
    }

    private func showCompletionScreen(with data: ChallengeFriendData, result: [(Int, Bool)]) {
        guard let navigationController = challengeFriendNavigationController else {
            return
        }
        let controller = UIHostingController(rootView: ChallengeFriendResultView(result: result, onContinue: {
            navigationController.dismiss(animated: true)
        }).environmentObject(store))
        navigationController.pushViewController(controller, animated: true)
    }
}
