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
    let programmingLanguage: ProgrammingLanguage
    let practiceSections: [String: Resolvable<[ChallengeSection]>]
    let practiceSectionsProgresses: [String: Resolvable<[IdProgressCouple]>]
    let collections: [Int: Resolvable<ChallengeCollectionContent>]
    let collectionProgresses: [Int: Resolvable<ChallengeCollectionContentProgress>]
    let challengeDetails: [Int: Resolvable<ChallengeDetail>]
    let challengeProgresses: [Int: Resolvable<ChallengeProgress>]
    let challengeResults: [Int: Resolvable<ChallengeCompiledResult>]
    let searchByInstances: [String: SearchState]
    let recommendedChallenges: Resolvable<[Challenge]>
    let inProgressChallenges: Resolvable<[Challenge]>
    let doneChallenges: Resolvable<[Challenge]>
    let rewards: Resolvable<[Reward]>
    let loadingReward: LoadingReward?
    let conceptReviews: [Int: Resolvable<ConceptReview>]
    let leaderboardData: Resolvable<LeaderboardData>
    let chatMessages: [String: [Resolvable<ChatMessage>]]
    let maintenance: Maintenance?
    let ongoingChallengeFriendData: Resolvable<ChallengeFriendData>
    let learnSections: [ProgrammingLanguage: Resolvable<LearnSections>]
    let learnSectionsProgress: [ProgrammingLanguage: Resolvable<LearnSectionsProgress>]
    let lessons: [Int: Resolvable<LessonCollection>]
    let lessonsProgress: [Int: Resolvable<LessonCollectionProgress>]

    init(user: Resolvable<User> = .pending,
         account: Resolvable<Account> = .pending,
         programmingLanguage: ProgrammingLanguage = .python,
         practiceSections: [String: Resolvable<[ChallengeSection]>] = [:],
         practiceSectionsProgresses: [String: Resolvable<[IdProgressCouple]>] = [:],
         collections: [Int: Resolvable<ChallengeCollectionContent>] = [:],
         collectionProgresses: [Int: Resolvable<ChallengeCollectionContentProgress>] = [:],
         challengeDetails: [Int: Resolvable<ChallengeDetail>] = [:],
         challengeProgresses: [Int: Resolvable<ChallengeProgress>] = [:],
         challengeResults: [Int: Resolvable<ChallengeCompiledResult>] = [:],
         searchByInstances: [String: SearchState] = [:],
         recommendedChallenges: Resolvable<[Challenge]> = .pending,
         inProgressChallenges: Resolvable<[Challenge]> = .pending,
         doneChallenges: Resolvable<[Challenge]> = .pending,
         rewards: Resolvable<[Reward]> = .pending,
         loadingReward: LoadingReward? = nil,
         conceptReviews: [Int: Resolvable<ConceptReview>] = [:],
         leaderboardData: Resolvable<LeaderboardData> = .pending,
         chatMessages: [String: [Resolvable<ChatMessage>]] = [:],
         maintenance: Maintenance? = nil,
         ongoingChallengeFriendData: Resolvable<ChallengeFriendData> = .pending,
         learnSections: [ProgrammingLanguage: Resolvable<LearnSections>] = [:],
         learnSectionsProgress: [ProgrammingLanguage: Resolvable<LearnSectionsProgress>] = [:],
         lessons: [Int: Resolvable<LessonCollection>] = [:],
         lessonsProgress: [Int: Resolvable<LessonCollectionProgress>] = [:]) {
        self.user = user
        self.account = account
        self.programmingLanguage = programmingLanguage
        self.practiceSections = practiceSections
        self.practiceSectionsProgresses = practiceSectionsProgresses
        self.collections = collections
        self.collectionProgresses = collectionProgresses
        self.challengeDetails = challengeDetails
        self.challengeProgresses = challengeProgresses
        self.challengeResults = challengeResults
        self.searchByInstances = searchByInstances
        self.recommendedChallenges = recommendedChallenges
        self.inProgressChallenges = inProgressChallenges
        self.doneChallenges = doneChallenges
        self.rewards = rewards
        self.loadingReward = loadingReward
        self.conceptReviews = conceptReviews
        self.leaderboardData = leaderboardData
        self.chatMessages = chatMessages
        self.maintenance = maintenance
        self.ongoingChallengeFriendData = ongoingChallengeFriendData
        self.learnSections = learnSections
        self.learnSectionsProgress = learnSectionsProgress
        self.lessons = lessons
        self.lessonsProgress = lessonsProgress
    }
}
