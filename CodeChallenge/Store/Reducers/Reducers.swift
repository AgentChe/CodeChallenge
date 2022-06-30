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
            user: userReducer(state.user, action)
        )
    }
}

extension Reducers {
    static let userReducer: Reducer<Resolvable<User>> = { state, action in
        switch action {
        case .loadUser(let user):
            return user
        }
    }
}
