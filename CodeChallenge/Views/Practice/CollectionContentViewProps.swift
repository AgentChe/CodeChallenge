//
//  NewCollectionContentViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/11/2022.
//

import Foundation

protocol CollectionContentViewProps {
    var store: Store { get }
    var collection: ChallengeCollection { get }
}

extension CollectionContentViewProps {
    var content: ChallengeCollectionContent? {
        store.state.collections[collection.id]?.value
    }
    
    var contentProgress: ChallengeCollectionContentProgress? {
        store.state.collectionProgresses[collection.id]?.value
    }

    var isLoading: Bool {
        store.state.collections[collection.id]?.isLoading == true
    }

    var xp: Int {
        store.state.account.value?.xp ?? 0
    }

    func getProgress(challenge: Challenge) -> String? {
        let progress = store.state.challengeProgresses[challenge.id]?.value?.type
        if progress == nil {
            return contentProgress?.challenges.first { $0.id == "\(challenge.id)" }?.progress
        }
        return progress
    }

    var showConceptReview: Bool {
        guard let conceptReviewId = collection.conceptReview?.id else { return false }
        return store.state.conceptReviews[conceptReviewId]?.value?.body.isEmpty == false
    }
}
