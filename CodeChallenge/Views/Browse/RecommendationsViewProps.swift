//
//  RecommendationsViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 21/11/2022.
//

import Foundation

protocol RecommendationsViewProps {
    var store: Store { get }
}

extension RecommendationsViewProps {
    var challenges: [Challenge] {
        store.state.recommendedChallenges.value ?? []
    }

    var isLoading: Bool {
        store.state.recommendedChallenges.isLoading ?? false
    }
}
