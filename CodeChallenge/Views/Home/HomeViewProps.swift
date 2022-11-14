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

    var xp: Int {
        store.state.account.value?.xp ?? 0
    }

    var homeViewComponents: [HomeView.Component] {
        guard let allGroups = challengeGroups else { return [] }
        let challengeGroups = allGroups.filter { $0.style != .collection }
        var components = challengeGroups.map { HomeView.Component.challengesGroup($0) }
        let collections = allGroups.filter { $0.style == .collection }
//        components.insert(.premium, at: 1)
        components.insert(.collection(collections), at: 1)
        return components
    }
}


