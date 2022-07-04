//
//  LoginCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import Foundation
import SwiftUI

class LoginCoordinator {
    let navigationController = UINavigationController()
    let store: Store

    init(store: Store) {
        self.store = store
    }

    func start() {
        let loginView = LoginView(screenMode: .login, onChangeMode: { [weak self] in
            self?.showSignUpView()
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: loginView)
        navigationController.setViewControllers([controller], animated: false)
    }

    func showSignUpView() {
        let loginView = LoginView(screenMode: .signup, onChangeMode: { [weak self] in
            self?.navigationController.popViewController(animated: true)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: loginView)
        navigationController.pushViewController(controller, animated: true)
    }
}
