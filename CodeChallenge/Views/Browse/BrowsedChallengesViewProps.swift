//
//  BrowsedChallengesViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/08/2022.
//

import Foundation

protocol BrowsedChallengesViewProps {
    var store: Store { get }
    var query: String { get }
}

extension BrowsedChallengesViewProps {
    var programmingLanguage: ProgrammingLanguage {
        store.state.programmingLanguage
    }

    var challenges: [Challenge] {
        store.state.searchByInstances[programmingLanguage.apiRequestParam]?.results.value ?? []
    }

    var isLoading: Bool {
        store.state.searchByInstances[programmingLanguage.apiRequestParam]?.results.isLoading ?? false
    }
}
