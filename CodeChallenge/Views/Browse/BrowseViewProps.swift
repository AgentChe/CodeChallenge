//
//  BrowseViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/08/2022.
//

import Foundation

protocol BrowseViewProps {
    var store: Store { get }
}

extension BrowseViewProps {
    var challengesToSuggest: [Challenge] {
        store.state.searchByInstances[programmingLanguage.apiRequestParam]?.results.value ?? []
    }

    var challengesAreLoading: Bool {
        store.state.searchByInstances[programmingLanguage.apiRequestParam]?.results.isLoading ?? false
    }

    var programmingLanguage: ProgrammingLanguage {
        store.state.programmingLanguage
    }

    var hashtags: [String] {
        store.state.searchByInstances[programmingLanguage.apiRequestParam]?.hashtags.value ?? []
    }

    var hashtagsAreLoading: Bool {
        store.state.searchByInstances[programmingLanguage.apiRequestParam]?.hashtags.isLoading ?? false
    }
}
