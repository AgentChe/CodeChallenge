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
    case loadAccount(Resolvable<Account>)
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

struct GuestAuth: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        dispatcher.services.authService.guestAuth()
            .asResolvable()
            .ephemeralSink { user in
                dispatcher.dispatch(Action.loadUser(user))
            }
    }
}

struct SignUp: ThunkAction {
    let email: String
    let username: String
    let password: String

    func exec(dispatcher: Dispatcher) {
        guard let id = dispatcher.state.user.value?.id, let session = dispatcher.state.user.value?.session else { return }

        dispatcher.services.authService.signUp(id: id, session: session, username: username, email: email, password: password)
            .asResolvable()
            .ephemeralSink { user in
                dispatcher.dispatch(Action.loadUser(user))
            }
    }
}

struct Signout: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        guard let session = dispatcher.state.user.value?.session else { return }

        dispatcher.services.authService.logout(session: session)
            .ephemeralSink { _ in
                dispatcher.dispatch(Action.loadUser(.pending))
            }
    }
}

struct LoadAccount: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        dispatcher.dispatch(Action.loadAccount(.loading))

        dispatcher.services.accountService.loadAccount()
            .asResolvable()
            .ephemeralSink { account in
                dispatcher.dispatch(Action.loadAccount(account))
            }
    }
}
