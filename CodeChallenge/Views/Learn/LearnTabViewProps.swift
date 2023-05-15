//
//  LearnTabViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 16/04/2023.
//

import Foundation

protocol LearnTabViewProps {
    var store: Store { get }
}

extension LearnTabViewProps {
    var xp: Int {
        store.state.account.value?.xp ?? 0
    }

    var programmingLanguage: ProgrammingLanguage {
        store.state.programmingLanguage
    }

    var isPremium: Bool {
        store.state.user.value?.isPremium == true
    }
}
