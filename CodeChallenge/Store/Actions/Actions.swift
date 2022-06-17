//
//  Actions.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation

protocol Dispatchable {}

enum Action: Dispatchable {
    case loadUser(Resolvable<User>)
}

protocol ThunkAction: Dispatchable {
    func exec(dispatcher: Dispatcher)
}

struct Login: ThunkAction {
    let username: String
    let password: String

    func exec(dispatcher: Dispatcher) {
        dispatcher.services.authService.login(username: username, password: password)
            .asResolvable()
            .ephemeralSink { user in
                dispatcher.dispatch(Action.loadUser(user))
            }
    }
}
