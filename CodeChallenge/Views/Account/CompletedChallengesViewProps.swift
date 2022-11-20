//
//  CompletedChallengesViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 20/11/2022.
//

import Foundation

protocol CompletedChallengesViewProps {
    var store: Store { get }
}

extension CompletedChallengesViewProps {
    var challenges: [Challenge] {
        store.state.doneChallenges.value ?? []
    }
}
