//
//  Reducers.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation

typealias Reducer<T> = (T, Action) -> T

struct Reducers {
    static let root: Reducer<AppState> = { state, action in
        AppState(
            user: userReducer(state.user, action),
            account: accountReducer(state.account, action),
            programmingLanguage: programmingLanguageReducer(state.programmingLanguage, action),
            homeSections: homeSectionsReducer(state.homeSections, action),
            collections: collectionContentReducer(state.collections, action),
            challengeDetails: challengeDetailsReducer(state.challengeDetails, action),
            challengeProgresses: challengeProgressReducer(state.challengeProgresses, action),
            challengeResults: challengeResultsReducer(state.challengeResults, action),
            searchByInstances: searchesByInstancesReducer(state.searchByInstances, action),
            recommendedChallenges: recommendedChallengesReducer(state.recommendedChallenges, action),
            inProgressChallenges: inProgressChallengesReducer(state.inProgressChallenges, action),
            doneChallenges: doneChallengesReducer(state.doneChallenges, action),
            payments: paymentsReducer(state.payments, action),
            rewards: rewardsReducer(state.rewards, action),
            loadingReward: loadingRewardReducer(state.loadingReward, action),
            conceptReviews: conceptReviewReducer(state.conceptReviews, action),
            leaderboardData: leaderboardReducer(state.leaderboardData, action),
            chatMessages: chatMessagesReducer(state.chatMessages, action),
            maintenance: maintenanceReducer(state.maintenance, action),
            ongoingChallengeFriendData: ongoingChallengeFriendDataReducer(state.ongoingChallengeFriendData, action),
            learnSections: learnSectionsReducer(state.learnSections, action),
            lessons: lessonsReducer(state.lessons, action)
        )
    }
}

extension Reducers {
    static let userReducer: Reducer<Resolvable<User>> = { state, action in
        switch action {
        case .loadUser(let user):
            return user
        default: return state
        }
    }
}

extension Reducers {
    static let accountReducer: Reducer<Resolvable<Account>> = { state, action in
        switch action {
        case .loadAccount(let account):
            return account
        default: return state
        }
    }
}

extension Reducers {
    static let challengeDetailsReducer: Reducer<[Int: Resolvable<ChallengeDetail>]> = { state, action in
        switch action {
        case .loadChallengeDetails(let details):
            var copy = state
            copy[details.0] = details.1
            return copy
        default: return state
        }
    }
}

extension Reducers {
    static let challengeResultsReducer: Reducer<[Int: Resolvable<ChallengeCompiledResult>]> = { state, action in
        switch action {
        case .loadChallengeCompiledResult(let details):
            var copy = state
            copy[details.0] = details.1
            return copy
        case .logout: return [:]
        default: return state
        }
    }
}

extension Reducers {
    static let challengeProgressReducer: Reducer<[Int: Resolvable<ChallengeProgress>]> = { state, action in
        switch action {
        case .loadChallengeProgress(let progress):
            var copy = state
            copy[progress.0] = progress.1
            return copy
        case .logout: return [:]
        default: return state
        }
    }
}

extension Reducers {
    static let searchesByInstancesReducer: Reducer<[String: SearchState]> = { state, action in
        switch action {
        case let .updateSearchQuery(identifier, query):
            var copyState = state
            copyState[identifier] = SearchState(query: query, results: state[identifier]?.results ?? .pending, hashtags: state[identifier]?.hashtags ?? .pending)
            return copyState
        case .loadSearchResults(let id, let results):
            var copyState = state
            copyState[id] = SearchState(query: state[id]?.query, results: results, hashtags: state[id]?.hashtags ?? .pending)
            return copyState
        case .resetSearch(let instanceId):
            var copyState = state
            copyState[instanceId] = SearchState(query: nil, results: .pending, hashtags: state[instanceId]?.hashtags ?? .pending)
            return copyState
        case .loadHashtags(let hashtags, let programmingLanguage):
            var copyState = state
            copyState[programmingLanguage.apiRequestParam] =
            SearchState(query: state[programmingLanguage.apiRequestParam]?.query, results: state[programmingLanguage.apiRequestParam]?.results ?? .pending, hashtags: hashtags)
            return copyState
        default: return state
        }
    }
}

extension Reducers {
    static let inProgressChallengesReducer: Reducer<Resolvable<[Challenge]>> = { state, action in
        switch action {
        case .loadInProgressChallenges(let challenges):
            return challenges
        case .logout:
            return .success([])
        default: return state
        }
    }
}

extension Reducers {
    static let doneChallengesReducer: Reducer<Resolvable<[Challenge]>> = { state, action in
        switch action {
        case .loadDoneChallenges(let challenges):
            return challenges
        case .logout:
            return .success([])
        default: return state
        }
    }
}

extension Reducers {
    static let recommendedChallengesReducer: Reducer<Resolvable<[Challenge]>> = { state, action in
        switch action {
        case .loadRecommendedChallenges(let challenges):
            return challenges
        default: return state
        }
    }
}

extension Reducers {
    static let paymentsReducer: Reducer<Resolvable<[AppStorePayment]>> = { state, action in
        switch action {
        case .loadPayments(let result):
            return result
        default: return state
        }
    }
}

extension Reducers {
    static let homeSectionsReducer: Reducer<[String: Resolvable<[ChallengeSection]>]> = { state, action in
        switch action {
        case .loadHomeSections(let identifier, let result):
            var copy = state
            copy[identifier] = result
            return copy
        default: return state
        }
    }
}

extension Reducers {
    static let learnSectionsReducer: Reducer<[ProgrammingLanguage: Resolvable<LearnSections>]> = { state, action in
        switch action {
        case .updateLearnSections(let identifier, let result):
            var copy = state
            copy[identifier] = result
            return copy
        default: return state
        }
    }
}

extension Reducers {
    static let lessonsReducer: Reducer<[Int: Resolvable<LessonCollection>]> = { state, action in
        switch action {
        case .updateLessonCollection(let identifier, let result):
            var copy = state
            copy[identifier] = result
            return copy
        default: return state
        }
    }
}

extension Reducers {
    static let collectionContentReducer: Reducer<[Int: Resolvable<ChallengeCollectionContent>]> = { state, action in
        switch action {
        case .loadHomeCollectionContent(let identifier, let result):
            var copy = state
            copy[identifier] = result
            return copy
        default: return state
        }
    }
}

extension Reducers {
    static let conceptReviewReducer: Reducer<[Int: Resolvable<ConceptReview>]> = { state, action in
        switch action {
        case .loadConceptReview(let identifier, let result):
            var copy = state
            copy[identifier] = result
            return copy
        default: return state
        }
    }
}

extension Reducers {
    static let programmingLanguageReducer: Reducer<ProgrammingLanguage> = { state, action in
        switch action {
        case .changeProgrammingLanguage(let language):
            return language
        default: return state
        }
    }
}

extension Reducers {
    static let rewardsReducer: Reducer<Resolvable<[Reward]>> = { state, action in
        switch action {
        case .loadRewards(let result): return result
        default: return state
        }
    }
}

extension Reducers {
    static let leaderboardReducer: Reducer<Resolvable<LeaderboardData>> = { state, action in
        switch action {
        case .updateLeaderboardData(let result): return result
        default: return state
        }
    }
}

extension Reducers {
    static let loadingRewardReducer: Reducer<LoadingReward?> = { state, action in
        switch action {
        case .updateLoadingReward(let result):
            return result
        default: return state
        }
    }
}

extension Reducers {
    static let maintenanceReducer: Reducer<Maintenance?> = { state, action in
        switch action {
        case .updateMaintenanceInfo(let result):
            return result
        default: return state
        }
    }
}

extension Reducers {
    static let ongoingChallengeFriendDataReducer: Reducer<Resolvable<ChallengeFriendData>> = { state, action in
        switch action {
        case .updateOngoingChallengeFriendData(let result):
            return result
        default: return state
        }
    }
}

extension Reducers {
    static let chatMessagesReducer: Reducer<[String: [Resolvable<ChatMessage>]]> = { state, action in
        switch action {
        case let .updateChatMessages(mode, index, new):
            if let index = index {
                var copy = state[mode.identifier]
                copy?.remove(at: index)
                copy?.insert(new, at: index)
                var newState = state
                newState[mode.identifier] = copy
                return newState
            } else {
                var copy = state[mode.identifier]
                if copy == nil {
                    copy = []
                }
                copy?.append(new)
                var newState = state
                newState[mode.identifier] = copy
                return newState
            }
        case let .deleteFailedMessages(mode):
            let identifier = mode.identifier
            var copy = state[identifier]
            copy?.removeAll(where: { $0.error != nil })
            var newState = state
            newState[identifier] = copy
            return newState
        default: return state
        }
    }
}
