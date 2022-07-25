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
    var getPremiumTexts: [String] {
        return ["Unlimited Coding Challenges", "Another random text", "3rd text and a reminder that I wanna sleep"]
    }

    var payments: [AppStorePayment] {
        return store.state.payments.value ?? []
    }
}
