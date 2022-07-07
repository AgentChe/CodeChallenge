//
//  Reducers.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation

typealias Reducer<T> = (T, Action) -> T

struct Reducers {
    static let root: Reducer<AppState> = { state, action in
        AppState(
            user: userReducer(state.user, action),
            account: accountReducer(state.account, action)
        )
    }
}

extension Reducers {
    static let userReducer: Reducer<Resolvable<User>> = { state, action in
        switch action {
        case .loadUser(let user):
            return user
        default: return state
        }
    }
}

extension Reducers {
    static let accountReducer: Reducer<Resolvable<Account>> = { state, action in
        switch action {
        case .loadAccount(let account):
            return account
        default: return state
        }
    }
}
