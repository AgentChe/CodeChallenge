//
//  NewHomeViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/11/2022.
//

import Foundation

protocol HomeViewProps {
    var store: Store { get }
    var humanLanguage: String { get }
}

extension HomeViewProps {
    var isLoading: Bool {
        store.state.homeSections[identifier]?.isLoading == true
    }

    var identifier: String {
        "\(programmingLanguage.apiRequestParam)_\(humanLanguage)"
    }

    var xp: Int {
        store.state.account.value?.xp ?? 0
    }

    var programmingLanguage: ProgrammingLanguage {
        store.state.programmingLanguage
    }
}

extension HomeViewProps {
    var challengesToSuggest: [Challenge] {
        store.state.searchByInstances[programmingLanguage.apiRequestParam]?.results.value ?? []
    }

    var challengesAreLoading: Bool {
        store.state.searchByInstances[programmingLanguage.apiRequestParam]?.results.isLoading ?? false
    }

    var hashtags: [String] {
        store.state.searchByInstances[programmingLanguage.apiRequestParam]?.hashtags.value ?? []
    }

    var hashtagsAreLoading: Bool {
        store.state.searchByInstances[programmingLanguage.apiRequestParam]?.hashtags.isLoading ?? false
    }
}
