//
//  PremiumViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 04/08/2022.
//

import Foundation

protocol PremiumViewProps {
    var store: Store { get }
}

extension PremiumViewProps {
    var getPremiumTexts: [(String, String)] {
        return [("Today", "do this which \n is a long text"), ("Next day", "do that \n aziz jan "), ("the day", "do this one \n ba ba")]
    }

    var payments: [AppStorePayment] {
        return store.state.payments.value ?? []
    }
}
