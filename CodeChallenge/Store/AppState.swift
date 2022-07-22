//
//  AppState.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation

struct AppState {
    let user: Resolvable<User>
    let account: Resolvable<Account>
    let challengeGroups: Resolvable<[ChallengeGroup]>

    init(user: Resolvable<User> = .pending,
         account: Resolvable<Account> = .pending,
         challengeGroups: Resolvable<[ChallengeGroup]> = .pending) {
        self.user = user
        self.account = account
        self.challengeGroups = challengeGroups
    }
}
