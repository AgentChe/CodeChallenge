//
//  SceneDelegate.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import Foundation
import UIKit
import Mixpanel

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
        window?.overrideUserInterfaceStyle = .light
        window?.backgroundColor = .CodeChallenge.dark
        window?.makeKeyAndVisible()

//        let statusBar = UIView()
//        statusBar.frame = window?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
//        statusBar.backgroundColor = .white
//        window?.addSubview(statusBar)

        Mixpanel.initialize(token: "4e8b61d12afcdad81dca5a29ef81425d")
    }
}
