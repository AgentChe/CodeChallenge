//
//  RootCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine

final class RootCoordinator {
    private let window: UIWindow
    private let store = Store()
    private let loginCoordinator: LoginCoordinator
    private let accountCoordinator: AccountCoordinator

    private var authCancellable: AnyCancellable?
    private var logoutCancellable: AnyCancellable?

    init(window: UIWindow) {
        self.window = window
        loginCoordinator = LoginCoordinator(store: store)
        accountCoordinator = AccountCoordinator(store: store)
    }

    func start() {
        window.rootViewController = loginCoordinator.navigationController
        loginCoordinator.start()

        authCancellable = self.store
            .statePublisher
            .map { $0.user.value?.username != nil }
            .removeDuplicates()
            .sink { [weak self] isLoggedIn in
                guard let self = self else { return }
                if isLoggedIn {
                    self.window.rootViewController = self.accountCoordinator.navigationController
                    self.accountCoordinator.start()
                }
            }

        logoutCancellable = self.store
            .statePublisher
            .map { $0.user.isPending }
            .removeDuplicates()
            .sink { [weak self] isLoggedOut in
                guard let self = self else { return }
                if isLoggedOut {
                    self.window.rootViewController = self.loginCoordinator.navigationController
                    self.loginCoordinator.start()
                }
            }

        store.dispatch(GuestAuth())
    }
}
