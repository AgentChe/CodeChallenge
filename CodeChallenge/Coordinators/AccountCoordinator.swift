//
//  AccountCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import SwiftUI

struct AccountCoordinator {
    let navigationController = UINavigationController()
    let store: Store

    func start() {
        let accountView = AccountView()
            .environmentObject(store)
        let controller = UIHostingController(rootView: accountView)
        navigationController.setViewControllers([controller], animated: false)
    }
}
