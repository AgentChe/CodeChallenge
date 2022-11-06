//
//  BrowsedChallengesViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/08/2022.
//

import Foundation

protocol BrowsedChallengesViewProps {
    var store: Store { get }
    var instanceID: UUID { get }
    var query: String { get }
}

extension BrowsedChallengesViewProps {
    var challenges: [Challenge] {
        store.state.searchByInstances[instanceID.uuidString]?.results.value ?? []
    }

    var isLoading: Bool {
        store.state.searchByInstances[instanceID.uuidString]?.results.isLoading ?? false
    }
}
