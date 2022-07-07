//
//  AppState.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation

struct AppState {
    let user: Resolvable<User>
    let account: Resolvable<Account>

    init(user: Resolvable<User> = .pending,
         account: Resolvable<Account> = .pending) {
        self.user = user
        self.account = account
    }
}
