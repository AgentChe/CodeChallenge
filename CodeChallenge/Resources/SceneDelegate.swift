//
//  SceneDelegate.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import Foundation
import UIKit
import Branch

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var rootCoordinator: RootCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo sceneSession: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let mainWindow = UIWindow(windowScene: windowScene)
        window = mainWindow
        rootCoordinator = RootCoordinator(window: mainWindow)
        rootCoordinator?.start()
        window?.overrideUserInterfaceStyle = .dark
        window?.backgroundColor = .CodeChallenge.dark
        window?.makeKeyAndVisible()

        if let userActivity = connectionOptions.userActivities.first {
            BranchScene.shared().scene(scene, continue: userActivity)
        } else if !connectionOptions.urlContexts.isEmpty {
            BranchScene.shared().scene(scene, openURLContexts: connectionOptions.urlContexts)
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        BranchScene.shared().scene(scene, continue: userActivity)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        BranchScene.shared().scene(scene, openURLContexts: URLContexts)
    }
}

extension SceneDelegate {
    func process(acceptedChallengeId: Int) {
        rootCoordinator?.process(challengeFriendId: acceptedChallengeId)
    }
}
