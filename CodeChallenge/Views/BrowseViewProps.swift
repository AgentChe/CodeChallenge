//
//  BrowseViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/08/2022.
//

import Foundation

protocol BrowseViewProps {
    var store: Store { get }
    var instanceID: UUID { get }
}

extension BrowseViewProps {
    var challengesToSuggest: [Challenge] {
        store.state.searchByInstances[instanceID.uuidString]?.results.value ?? []
    }

    var challengesAreLoading: Bool {
        store.state.searchByInstances[instanceID.uuidString]?.results.isLoading ?? false
    }

    var hashtags: [String] {
        store.state.searchByInstances[instanceID.uuidString]?.hashtags.value ?? []
    }

    var hashtagsAreLoading: Bool {
        store.state.searchByInstances[instanceID.uuidString]?.hashtags.isLoading ?? false
    }
}
