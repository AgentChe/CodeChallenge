//
//  NewCollectionContentViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/11/2022.
//

import Foundation

protocol NewCollectionContentViewProps {
    var store: Store { get }
    var collection: NewChallengeCollection { get }
    var section: NewChallengeSection { get }
}

extension NewCollectionContentViewProps {
    var content: NewChallengeCollectionContent? {
        store.state.collections[collection.id]?.value
    }

    var isLoading: Bool {
        store.state.collections[collection.id]?.isLoading == true
    }

    var xp: Int {
        store.state.account.value?.xp ?? 0
    }
}
