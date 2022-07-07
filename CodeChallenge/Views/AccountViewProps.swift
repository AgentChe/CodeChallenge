//
//  AccountViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation

protocol AccountViewProps {
    var store: Store { get }
}

extension AccountViewProps {
    var account: Account? {
        store.state.account.value
    }

    var isLoading: Bool {
        store.state.account.isLoading
    }
}
