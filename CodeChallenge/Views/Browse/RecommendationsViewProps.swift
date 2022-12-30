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

    func getProgress(challenge: Challenge) -> String? {
        let progress = store.state.challengeProgresses[challenge.id]?.value?.type
        if progress == nil {
            return challenges.first { $0.id == challenge.id }?.progress
        }
        return progress
    }
}
