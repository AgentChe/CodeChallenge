//
//  Actions.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import Mixpanel

protocol Dispatchable {}

enum Action: Dispatchable {
    case loadUser(Resolvable<User>)
    case loadAccount(Resolvable<Account>)
    case loadChallengeGroups(Resolvable<[ChallengeGroup]>)
    case loadChallengeDetails((Int, Resolvable<ChallengeDetail>))
    case loadChallengeProgress((Int, Resolvable<ChallengeProgress>))
    case loadChallengeCompiledResult((Int, Resolvable<ChallengeCompiledResult>))
    case updateSearchQuery(String, String)
    case loadSearchResults(String, Resolvable<[Challenge]>)
    case resetSearch(String)
    case loadInProgressChallenges(Resolvable<[Challenge]>)
    case loadDoneChallenges(Resolvable<[Challenge]>)
    case logout
    case loadPayments(Resolvable<[AppStorePayment]>)
    case loadHashtags(Resolvable<[String]>, String)
    case loadHomeSections(String, Resolvable<[NewChallengeSection]>)
    case loadHomeCollectionContent(Int, Resolvable<NewChallengeCollectionContent>)
}

protocol ThunkAction: Dispatchable {
    func exec(dispatcher: Dispatcher)
}

struct Login: ThunkAction {
    let username: String
    let password: String

    func exec(dispatcher: Dispatcher) {
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session") else { return }
        let id = UserDefaults.standard.integer(forKey: "cc_user_id")

        dispatcher.services.authService.login(id: id, session: session, username: username, password: password)
            .asResolvable()
            .ephemeralSink { user in
                if user.isSuccess {
                    dispatcher.dispatch(AddStreakIfNeeded())
                    dispatcher.dispatch(TrackAnalyticsEvent(event: .loginSuccessful))
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(user.value?.session, forKey: "cc_user_session")
                    UserDefaults.standard.set(user.value?.id, forKey: "cc_user_id")
                    dispatcher.dispatch(Action.loadUser(user))
                } else {
                    dispatcher.dispatch(Action.loadUser(user))
                }
            }
    }
}

struct Logout: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        let session = UserDefaults.standard.string(forKey: "cc_user_session")
        guard let session = session else { return }
        dispatcher.services.authService
            .logout(session: session)
            .ephemeralSink { _ in
                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                UserDefaults.standard.set(nil, forKey: "cc_user_session")
                UserDefaults.standard.set(nil, forKey: "cc_user_id")
                dispatcher.dispatch(Action.logout)
                dispatcher.dispatch(GuestAuth())
            }
    }
}

struct LoadHashtags: ThunkAction {
    let instanceID: UUID

    func exec(dispatcher: Dispatcher) {
        dispatcher.dispatch(Action.loadHashtags(.loading, instanceID.uuidString))
        dispatcher.services
            .challengesService
            .loadHashtags()
            .asResolvable()
            .ephemeralSink { strings in
                dispatcher.dispatch(Action.loadHashtags(strings, instanceID.uuidString))
            }
    }
}

struct DeleteAccount: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        let session = UserDefaults.standard.string(forKey: "cc_user_session")
        let id = UserDefaults.standard.integer(forKey: "cc_user_id")
        guard let session = session else { return }
        dispatcher.services.authService
            .deleteAccount(session: session, id: id)
            .ephemeralSink { _ in
                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                UserDefaults.standard.set(nil, forKey: "cc_user_session")
                UserDefaults.standard.set(nil, forKey: "cc_user_id")
                dispatcher.dispatch(Action.logout)
                dispatcher.dispatch(GuestAuth())
            }
    }
}

struct GuestAuth: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        let session = UserDefaults.standard.string(forKey: "cc_user_session")
        guard session == nil else {
            dispatcher.dispatch(LoadAccount())
            return
        }
        dispatcher.dispatch(Action.loadAccount(.loading))
        dispatcher.services.authService.guestAuth()
            .asResolvable()
            .ephemeralSink { user in
                if user.isSuccess {
                    UserDefaults.standard.set(user.value?.session, forKey: "cc_user_session")
                    UserDefaults.standard.set(user.value?.id, forKey: "cc_user_id")
                    dispatcher.dispatch(Action.loadUser(user))
                    dispatcher.dispatch(LoadAccount())
                    dispatcher.dispatch(LoadChallengeGroups())
                }
            }
    }
}

struct SignUp: ThunkAction {
    let email: String
    let username: String
    let password: String

    func exec(dispatcher: Dispatcher) {
        let id = UserDefaults.standard.integer(forKey: "cc_user_id")
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session") else { return }

        dispatcher.services.authService.signUp(id: id, session: session, username: username, email: email, password: password)
            .asResolvable()
            .ephemeralSink { user in
                if user.isSuccess {
                    dispatcher.dispatch(AddStreakIfNeeded())
                    dispatcher.dispatch(TrackAnalyticsEvent(event: .signUpSuccessful))
                    UserDefaults.standard.set(user.value?.session, forKey: "cc_user_session")
                    UserDefaults.standard.set(user.value?.id, forKey: "cc_user_id")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    dispatcher.dispatch(Action.loadUser(user))
                } else {
                    dispatcher.dispatch(Action.loadUser(user))
                }
            }
    }
}

struct Signout: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        guard let session = dispatcher.state.user.value?.session else { return }

        dispatcher.services.authService.logout(session: session)
            .ephemeralSink { _ in
                dispatcher.dispatch(Action.loadUser(.pending))
                UserDefaults.standard.removeObject(forKey: "cc_user_session")
                UserDefaults.standard.removeObject(forKey: "cc_user_id")
            }
    }
}

struct LoadAccount: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        guard UserDefaults.standard.string(forKey: "cc_user_session") != nil,
              UserDefaults.standard.integer(forKey: "cc_user_id") != 0 else { return }
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")
        dispatcher.dispatch(Action.loadAccount(.loading))

        let account = Account()

        dispatcher.services.accountService.loadAccount(userId: userId)
            .ephemeralSink { user in
                account.username = user.username
                account.streak = user.streak
                account.id = user.id
                account.xp = user.xp
                account.solvedChallenges = user.doneChallangeCount

                dispatcher.dispatch(Action.loadAccount(.success(account)))
            }

        dispatcher.dispatch(LoadInProgressChallenges())
        dispatcher.dispatch(LoadCompletedChallenges())

//        dispatchGroup.enter()
//        dispatcher.services.accountService
//            .getFollowersCount(userId: 4)
//            .ephemeralSink { count in
//                dispatchGroup.leave()
//                account.followersCount = count
//            }
//
//        dispatchGroup.enter()
//        dispatcher.services.accountService
//            .getFollowingCount(userId: 4)
//            .ephemeralSink { count in
//                dispatchGroup.leave()
//                account.followingsCount = count
//            }
    }
}

struct LoadInProgressChallenges: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        dispatcher.dispatch(Action.loadInProgressChallenges(.loading))
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")

        dispatcher.services.accountService
            .getChallengeProgress(userId: userId)
            .asResolvable()
            .ephemeralSink { progresses in
                dispatcher.dispatch(Action.loadInProgressChallenges(progresses))
            }
    }
}

struct LoadCompletedChallenges: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        dispatcher.dispatch(Action.loadInProgressChallenges(.loading))
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")

        dispatcher.services.accountService
            .getChallengeDones(userId: userId)
            .asResolvable()
            .ephemeralSink { progresses in
                dispatcher.dispatch(Action.loadDoneChallenges(progresses))
            }
    }
}

struct LoadChallengeGroups: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")
        dispatcher.dispatch(Action.loadChallengeGroups(.loading))

        dispatcher.services.challengesService
            .fetchChallengeGroups(id: userId, lang: "en")
            .asResolvable()
            .ephemeralSink { groups in
                dispatcher.dispatch(Action.loadChallengeGroups(groups))
            }
    }
}

struct AddStreakIfNeeded: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        let session = UserDefaults.standard.string(forKey: "cc_user_session")
        dispatcher.services
            .accountService
            .addStreak(session: session ?? "")
            .ephemeralSink { _ in
                dispatcher.dispatch(LoadAccount())
            }
    }
}

struct LoadChallengeDetails: ThunkAction {
    let id: Int

    func exec(dispatcher: Dispatcher) {
        if dispatcher.state.challengeDetails[id] == nil {
            dispatcher.dispatch(Action.loadChallengeDetails((id, .loading)))
        }

        dispatcher.services.challengesService
            .fetchChallenge(id: id)
            .asResolvable()
            .ephemeralSink { detail in
                dispatcher.dispatch(Action.loadChallengeDetails((id, detail)))
            }
    }
}

struct LoadChallengeProgress: ThunkAction {
    let challengeId: Int

    func exec(dispatcher: Dispatcher) {
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")

        dispatcher
            .services.challengesService
            .getChallengeProgress(id: challengeId, userId: userId)
            .asResolvable()
            .ephemeralSink { progress in
                dispatcher.dispatch(Action.loadChallengeProgress((challengeId, progress)))
            }
    }
}

struct UpdateChallengeProgress: ThunkAction {
    let challenge: Challenge
    let solution: String
    let compile: Bool

    func exec(dispatcher: Dispatcher) {
        let session = UserDefaults.standard.string(forKey: "cc_user_session") ?? ""
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")
        let challengeId = challenge.id

        let currentProgressType = dispatcher.state.challengeProgresses[challenge.id]?.value?.progress ?? 0

        let compileIfNeeded = {
            guard compile else { return }
            dispatcher.dispatch(Action.loadChallengeCompiledResult((challengeId, .loading)))
            dispatcher.services
                .challengesService.compile(id: userId, challengeId: challengeId, session: session)
                .asResolvable()
                .ephemeralSink { result in
                    dispatcher.dispatch(TrackAnalyticsEvent(event: .challengeCompleted(challenge, result.value?.isSuccesful == true)))
                    dispatcher.dispatch(Action.loadChallengeCompiledResult((challengeId, result)))

                    let progress = dispatcher.state.challengeProgresses[challengeId]?.value

                    if result.value?.isSuccesful == true, currentProgressType != 100 {
                        dispatcher.services.challengesService.updateChallengeProgress(id: challengeId, progressId: progress?.id ?? 0, session: session, solution: solution, type: "done")
                            .ephemeralSink { _ in
                                dispatcher.dispatch(LoadAccount())
                                dispatcher.dispatch(LoadChallengeGroups())
                                dispatcher.dispatch(LoadInProgressChallenges())
                                dispatcher.dispatch(LoadCompletedChallenges())
                            }
                    }
                }
        }

        if compile {
            dispatcher.dispatch(Action.loadChallengeCompiledResult((challengeId, .loading)))
        }

        if let progress = dispatcher.state.challengeProgresses[challengeId]?.value, progress.id != nil {
            dispatcher.dispatch(Action.loadChallengeProgress((challengeId, .loading)))
            dispatcher
                .services.challengesService
                .updateChallengeProgress(id: challengeId, progressId: progress.id ?? 0, session: session, solution: solution, type: currentProgressType != 100 ? "inprogress": "done")
                .asResolvable()
                .ephemeralSink{ nothing in
                    if nothing.isSuccess {
                        let newProgress = ChallengeProgress(
                            id: progress.id,
                            dateCreated: progress.dateCreated,
                            dateModified: progress.dateModified,
                            challengeId: progress.challengeId,
                            userId: progress.userId,
                            type: progress.type,
                            progress: progress.progress,
                            solution: .init(python: solution),
                            spentTime: progress.spentTime
                        )
                        dispatcher.dispatch(Action.loadChallengeProgress((challengeId, .success(newProgress))))
                    } else {
                        dispatcher.dispatch(Action.loadChallengeProgress((challengeId, .failure(NetworkError.internalInconsistency))))
                    }

                    compileIfNeeded()
                }
        } else {
            dispatcher.dispatch(Action.loadChallengeProgress((challengeId, .loading)))
            dispatcher
                .services.challengesService
                .addChallengeProgress(id: challengeId, session: session, solution: solution)
                .asResolvable()
                .ephemeralSink { progress in
                    dispatcher.dispatch(LoadInProgressChallenges())
                    dispatcher.dispatch(LoadChallengeGroups())
                    dispatcher.dispatch(Action.loadChallengeProgress((challengeId, progress)))
                    compileIfNeeded()
                }
        }
    }
}

struct UpdateSearchQuery: ThunkAction {
    let query: String
    let instanceId: UUID

    func exec(dispatcher: Dispatcher) {
        dispatcher.dispatch(Action.updateSearchQuery(instanceId.uuidString, query))
    }
}

struct LoadSearchResults: ThunkAction {
    let instanceId: UUID

    func exec(dispatcher: Dispatcher) {
        guard let searchState = dispatcher.state.searchByInstances[instanceId.uuidString] else { return }
        dispatcher.dispatch(Action.loadSearchResults(instanceId.uuidString, .loading))

        dispatcher.services
            .challengesService
            .searchChallenges(with: searchState.query ?? "", session: "")
            .asResolvable()
            .ephemeralSink { results in
                dispatcher.dispatch(Action.loadSearchResults(instanceId.uuidString, results))
            }
    }
}

struct TrackAnalyticsEvent: ThunkAction {
    let event: AnalyticsEvent
    func exec(dispatcher: Dispatcher) {
        dispatcher.services.analyticsService
            .track(event: event, properties: event.properties)
    }
}

struct LoadAppStorePayments: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        dispatcher.dispatch(Action.loadPayments(.loading))
        IAPManager.shared.startWith(arrayOfIds: Set<String>(
            ["yeary_7day_trial", "monthly_subscription", "yearly_pro_2week_trial"]
        ))
        IAPManager.shared.onLoadPayments = { payments in
            dispatcher.dispatch(Action.loadPayments(.success(payments)))
        }
    }
}

struct UploadImage: ThunkAction {
    let image: Data

    func exec(dispatcher: Dispatcher) {
        let session = UserDefaults.standard.string(forKey: "cc_user_session") ?? ""

        dispatcher.services
            .accountService
            .uploadImage(session: session, imageData: image)
            .ephemeralSink { _ in
                let copyAccount = dispatcher.state.account
                dispatcher.dispatch(Action.loadAccount(copyAccount))
            }
    }
}

struct LoadHomeSections: ThunkAction {
    let language: String
    let humanLanguage: String

    func exec(dispatcher: Dispatcher) {
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")
        if dispatcher.state.homeSections["\(language)_\(humanLanguage)"]?.value == nil {
            dispatcher.dispatch(Action.loadHomeSections("\(language)_\(humanLanguage)", .loading))
        }

        dispatcher.services.challengesService
            .fetchHomeSections(language: language, humanLanguage: humanLanguage, id: userId)
            .asResolvable()
            .ephemeralSink { groups in
                dispatcher.dispatch(Action.loadHomeSections("\(language)_\(humanLanguage)", groups))
            }
    }
}

struct LoadCollectionContent: ThunkAction {
    let collection: NewChallengeCollection

    func exec(dispatcher: Dispatcher) {
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")
        if dispatcher.state.collections[collection.id]?.value == nil {
            dispatcher.dispatch(Action.loadHomeCollectionContent(collection.id, .loading))
        }

        dispatcher.services.challengesService
            .fetchCollectionContent(id: userId, groupId: collection.id)
            .asResolvable()
            .ephemeralSink { groups in
                dispatcher.dispatch(Action.loadHomeCollectionContent(collection.id, groups))
            }
    }
}
