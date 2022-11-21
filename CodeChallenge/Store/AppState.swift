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
    let homeSections: [String: Resolvable<[NewChallengeSection]>]
    let collections: [Int: Resolvable<NewChallengeCollectionContent>]
    let challengeDetails: [Int: Resolvable<ChallengeDetail>]
    let challengeProgresses: [Int: Resolvable<ChallengeProgress>]
    let challengeResults: [Int: Resolvable<ChallengeCompiledResult>]
    let searchByInstances: [String: SearchState]
    let recommendedChallenges: Resolvable<[Challenge]>
    let inProgressChallenges: Resolvable<[Challenge]>
    let doneChallenges: Resolvable<[Challenge]>
    let payments: Resolvable<[AppStorePayment]>

    init(user: Resolvable<User> = .pending,
         account: Resolvable<Account> = .pending,
         challengeGroups: Resolvable<[ChallengeGroup]> = .pending,
         homeSections: [String: Resolvable<[NewChallengeSection]>] = [:],
         collections: [Int: Resolvable<NewChallengeCollectionContent>] = [:],
         challengeDetails: [Int: Resolvable<ChallengeDetail>] = [:],
         challengeProgresses: [Int: Resolvable<ChallengeProgress>] = [:],
         challengeResults: [Int: Resolvable<ChallengeCompiledResult>] = [:],
         searchByInstances: [String: SearchState] = [:],
         recommendedChallenges: Resolvable<[Challenge]> = .pending,
         inProgressChallenges: Resolvable<[Challenge]> = .pending,
         doneChallenges: Resolvable<[Challenge]> = .pending,
         payments: Resolvable<[AppStorePayment]> = .pending) {
        self.user = user
        self.account = account
        self.challengeGroups = challengeGroups
        self.homeSections = homeSections
        self.collections = collections
        self.challengeDetails = challengeDetails
        self.challengeProgresses = challengeProgresses
        self.challengeResults = challengeResults
        self.searchByInstances = searchByInstances
        self.recommendedChallenges = recommendedChallenges
        self.inProgressChallenges = inProgressChallenges
        self.payments = payments
        self.doneChallenges = doneChallenges
    }
}

struct SearchState {
    let query: String?
    let results: Resolvable<[Challenge]>
    let hashtags: Resolvable<[String]>
}
