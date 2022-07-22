//
//  HomeViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation

protocol HomeViewProps {
    var store: Store { get }
}

extension HomeViewProps {
    var challengeGroups: [ChallengeGroup]? {
        store.state.challengeGroups.value
    }

    var isLoading: Bool {
        store.state.challengeGroups.isLoading
    }

    var homeViewComponents: [HomeView.Component] {
        guard let challengeGroups = challengeGroups else { return [] }
        var components = challengeGroups.map { HomeView.Component.challengesGroup($0) }
        components.insert(.premium, at: 1)
        return components
    }

    func tags(_ challenge: Challenge) -> String {
        challenge.tags.reduce("") { partialResult, result in
            return partialResult + " #\(result)"
        }
    }
}


