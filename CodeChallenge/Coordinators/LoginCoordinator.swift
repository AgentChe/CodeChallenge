//
//  LoginCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import Foundation
import SwiftUI

struct LoginCoordinator {
    let navigationController = UINavigationController()
    let store: Store

    func start() {
        let loginView = LoginView()
            .environmentObject(store)
        let controller = UIHostingController(rootView: loginView)
        navigationController.setViewControllers([controller], animated: false)
    }
}
