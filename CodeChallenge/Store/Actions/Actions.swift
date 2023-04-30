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
    case loadChallengeDetails((Int, Resolvable<ChallengeDetail>))
    case loadChallengeProgress((Int, Resolvable<ChallengeProgress>))
    case loadChallengeCompiledResult((Int, Resolvable<ChallengeCompiledResult>))
    case updateSearchQuery(String, String)
    case loadSearchResults(String, Resolvable<[Challenge]>)
    case resetSearch(String)
    case loadInProgressChallenges(Resolvable<[Challenge]>)
    case loadRecommendedChallenges(Resolvable<[Challenge]>)
    case loadDoneChallenges(Resolvable<[Challenge]>)
    case logout
    case loadPayments(Resolvable<[AppStorePayment]>)
    case loadHashtags(Resolvable<[String]>, ProgrammingLanguage)
    case loadHomeSections(String, Resolvable<[ChallengeSection]>)
    case loadHomeCollectionContent(Int, Resolvable<ChallengeCollectionContent>)
    case changeProgrammingLanguage(ProgrammingLanguage)
    case loadRewards(Resolvable<[Reward]>)
    case updateLoadingReward(LoadingReward?)
    case loadConceptReview(Int, Resolvable<ConceptReview>)
    case updateLeaderboardData(Resolvable<LeaderboardData>)
    case updateChatMessages(mode: ChatMessagesMode, index: Int?, message: Resolvable<ChatMessage>)
    case updateMaintenanceInfo(Maintenance?)
    case deleteFailedMessages(mode: ChatMessagesMode)
    case updateOngoingChallengeFriendData(Resolvable<ChallengeFriendData>)
    case updateLearnSections(ProgrammingLanguage, Resolvable<LearnSections>)
    case updateLessonCollection(Int, Resolvable<LessonCollection>)
}

protocol ThunkAction: Dispatchable {
    func exec(dispatcher: Dispatcher)
}

struct Login: ThunkAction {
    let username: String
    let password: String
    let merge: Bool

    func exec(dispatcher: Dispatcher) {
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session") else { return }
        let previousAccount = dispatcher.state.account
        dispatcher.dispatch(Action.loadAccount(.loading))
        dispatcher.services.authService.login(merge: merge, session: session, username: username, password: password)
            .asResolvable()
            .ephemeralSink { user in
                if user.isSuccess {
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(user.value?.session, forKey: "cc_user_session")
                    UserDefaults.standard.set(user.value?.id, forKey: "cc_user_id")
                    dispatcher.dispatch(TrackAnalyticsEvent(event: .loginSuccessful))
                    dispatcher.dispatch(AddStreakIfNeeded())
                    dispatcher.dispatch(LoadHomeSections())
                    dispatcher.dispatch(Action.loadUser(user))
                } else {
                    dispatcher.dispatch(Action.loadUser(user))
                    dispatcher.dispatch(Action.loadAccount(previousAccount))
                }
            }
    }
}

struct Logout: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        let session = UserDefaults.standard.string(forKey: "cc_user_session")
        guard let session = session else { return }
        let previousAccount = dispatcher.state.account
        dispatcher.dispatch(Action.loadAccount(.pending))
        dispatcher.services.authService
            .logout(session: session)
            .asResolvable()
            .ephemeralSink { result in
                if result.isSuccess {
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    UserDefaults.standard.set(nil, forKey: "cc_user_session")
                    UserDefaults.standard.set(nil, forKey: "cc_user_id")
                    dispatcher.dispatch(Action.logout)
                    dispatcher.services.identifyService.removeIdentity()
                    dispatcher.dispatch(GuestAuth(reloadHome: true))
                } else {
                    dispatcher.dispatch(Action.loadAccount(previousAccount))
                }
            }
    }
}

struct LoadHashtags: ThunkAction {
    let programmingLanguage: ProgrammingLanguage

    func exec(dispatcher: Dispatcher) {
        dispatcher.dispatch(Action.loadHashtags(.loading, programmingLanguage))
        dispatcher.services
            .challengesService
            .loadHashtags(programmingLanguage: programmingLanguage)
            .asResolvable()
            .ephemeralSink { strings in
                dispatcher.dispatch(Action.loadHashtags(strings, programmingLanguage))
            }
    }
}

struct DeleteAccount: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        let session = UserDefaults.standard.string(forKey: "cc_user_session")
        let id = UserDefaults.standard.integer(forKey: "cc_user_id")
        guard let session = session else { return }
        let previousAccount = dispatcher.state.account
        dispatcher.dispatch(Action.loadAccount(.pending))
        dispatcher.services.authService
            .deleteAccount(session: session, id: id)
            .asResolvable()
            .ephemeralSink { result in
                if result.isSuccess {
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    UserDefaults.standard.set(nil, forKey: "cc_user_session")
                    UserDefaults.standard.set(nil, forKey: "cc_user_id")
                    dispatcher.dispatch(Action.logout)
                    dispatcher.services.identifyService.removeIdentity()
                    dispatcher.dispatch(GuestAuth(reloadHome: true))
                } else {
                    dispatcher.dispatch(Action.loadAccount(previousAccount))
                }
            }
    }
}

struct GuestAuth: ThunkAction {
    let reloadHome: Bool

    init(reloadHome: Bool = false) {
        self.reloadHome = reloadHome
    }
    func exec(dispatcher: Dispatcher) {
        let session = UserDefaults.standard.string(forKey: "cc_user_session")
        guard session == nil else {
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
                    dispatcher.dispatch(LoadInProgressChallenges())
                    dispatcher.dispatch(LoadCompletedChallenges())
                    if reloadHome {
                        dispatcher.dispatch(LoadHomeSections())
                    }
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
        let previousAccount = dispatcher.state.account
        dispatcher.dispatch(Action.loadAccount(.loading))
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
                    dispatcher.dispatch(Action.loadAccount(previousAccount))
                }
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
                account.isPremium = user.isPremium
                dispatcher.dispatch(Action.loadAccount(.success(account)))
                dispatcher.services.identifyService.identify(id: user.id)
                dispatcher.dispatch(LoadLeaderboardData())
            }
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

struct LoadRecommendedChallenges: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        dispatcher.dispatch(Action.loadRecommendedChallenges(.loading))
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")
        let programmingLanguage = dispatcher.state.programmingLanguage

        dispatcher.services.challengesService
            .getRecommendedChallenges(userId: userId, programmingLanguage: programmingLanguage)
            .asResolvable()
            .ephemeralSink { progresses in
                dispatcher.dispatch(Action.loadRecommendedChallenges(progresses))
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

struct LoadChallengeDetailsAndResetProgress: ThunkAction {
    let id: Int
    let programmingLanguage: ProgrammingLanguage

    func exec(dispatcher: Dispatcher) {
        if dispatcher.state.challengeDetails[id] == nil {
            dispatcher.dispatch(Action.loadChallengeDetails((id, .loading)))
        }

        dispatcher.services.challengesService
            .fetchChallenge(id: id)
            .asResolvable()
            .ephemeralSink { detail in
                dispatcher.dispatch(Action.loadChallengeDetails((id, detail)))
                if let value = detail.value {
                    dispatcher.dispatch(LoadChallengeProgress(challengeId: id, onComplete: {
                        dispatcher.dispatch(UpdateChallengeProgress(challengeId: id,
                                                                    solution: value.body.template,
                                                                    compile: false,
                                                                    programmingLanguage: programmingLanguage,
                                                                    language: "en"))
                    }))
                }
            }
    }
}

struct LoadChallengeProgress: ThunkAction {
    let challengeId: Int
    let onComplete: (() -> Void)?

    func exec(dispatcher: Dispatcher) {
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")

        dispatcher
            .services.challengesService
            .getChallengeProgress(id: challengeId, userId: userId)
            .asResolvable()
            .ephemeralSink { progress in
                dispatcher.dispatch(Action.loadChallengeProgress((challengeId, progress)))
                onComplete?()
            }
    }
}

struct UpdateChallengeProgress: ThunkAction {
    let challengeId: Int
    let solution: String
    let compile: Bool
    let programmingLanguage: ProgrammingLanguage
    let language: String

    func exec(dispatcher: Dispatcher) {
        let session = UserDefaults.standard.string(forKey: "cc_user_session") ?? ""
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")

        let currentProgressType = dispatcher.state.challengeProgresses[challengeId]?.value?.type

        let compileIfNeeded = {
            guard compile else { return }
            dispatcher.dispatch(Action.loadChallengeCompiledResult((challengeId, .loading)))
            dispatcher.services
                .challengesService.compile(id: userId, challengeId: challengeId, session: session, programmingLanguage: programmingLanguage)
                .asResolvable()
                .ephemeralSink { result in
                    dispatcher.dispatch(TrackAnalyticsEvent(event: .challengeCompleted(challengeId, result.value?.isSuccesful == true)))
                    dispatcher.dispatch(Action.loadChallengeCompiledResult((challengeId, result)))

                    let progress = dispatcher.state.challengeProgresses[challengeId]?.value

                    if result.value?.isSuccesful == true, currentProgressType != "done" {
                        dispatcher.services.challengesService.updateChallengeProgress(id: challengeId, progressId: progress?.id ?? 0, session: session, solution: solution, type: "done")
                            .ephemeralSink { _ in
                                dispatcher.dispatch(LoadHomeSections()) // FIXME:
                                dispatcher.dispatch(LoadAccount())
                                dispatcher.dispatch(LoadInProgressChallenges())
                                dispatcher.dispatch(LoadCompletedChallenges())
                                dispatcher.dispatch(LoadChallengeProgress(challengeId: challengeId, onComplete: nil))
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
                .updateChallengeProgress(id: challengeId, progressId: progress.id ?? 0, session: session, solution: solution, type: currentProgressType != "done" ? "inprogress": "done")
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
                    dispatcher.dispatch(Action.loadChallengeProgress((challengeId, progress)))
                    compileIfNeeded()
                }
        }
    }
}

struct UpdateSearchQuery: ThunkAction {
    let query: String

    func exec(dispatcher: Dispatcher) {
        let programmingLanguage = dispatcher.state.programmingLanguage
        dispatcher.dispatch(Action.updateSearchQuery(programmingLanguage.apiRequestParam, query))
    }
}

struct LoadSearchResults: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        let programmingLanguage = dispatcher.state.programmingLanguage
        guard let searchState = dispatcher.state.searchByInstances[programmingLanguage.apiRequestParam] else { return }
        dispatcher.dispatch(Action.loadSearchResults(programmingLanguage.apiRequestParam, .loading))

        dispatcher.services
            .challengesService
            .searchChallenges(with: searchState.query ?? "", programmingLanguage: programmingLanguage, session: "")
            .asResolvable()
            .ephemeralSink { results in
                dispatcher.dispatch(Action.loadSearchResults(programmingLanguage.apiRequestParam, results))
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
            ["monthly_subscription", "yearly_pro_2week_trial"]
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

struct PurchasePayment: ThunkAction {
    let payment: AppStorePayment

    func exec(dispatcher: Dispatcher) {
        let previousAccount = dispatcher.state.account.value

        IAPManager.shared.purchaseProduct(product: payment, success: { identifier in
            guard previousAccount?.isPremium == false else { return }
            dispatcher.services.purchasesService.send(
                receipt: IAPManager.shared.receiptData ?? "",
                userId: previousAccount?.id ?? 0
            )
            .ephemeralSink { _ in
                dispatcher.dispatch(TrackAnalyticsEvent(event: .premiumSucceeded(payment.productIdentifier)))
                dispatcher.dispatch(LoadAccount())
            }
        }, failure: { error in
        })
    }
}

struct RestorePurchases: ThunkAction {
    let completionBlock: ((Bool) -> Void)?

    func exec(dispatcher: Dispatcher) {
        let previousAccount = dispatcher.state.account.value

        IAPManager.shared.restorePurchases(success: { identifier in
            guard previousAccount?.isPremium == false else { return }
            dispatcher.services.purchasesService.send(
                receipt: IAPManager.shared.receiptData ?? "",
                userId: previousAccount?.id ?? 0
            )
            .ephemeralSink { _ in
                completionBlock?(true)
                dispatcher.dispatch(LoadAccount())
            }
        }, failure: { error in
            completionBlock?(false)
        })
    }
}

struct LoadHomeSections: ThunkAction {
    let language: ProgrammingLanguage?
    let humanLanguage: String

    init(language: ProgrammingLanguage? = nil) {
        self.humanLanguage = "en"
        self.language = language
    }

    func exec(dispatcher: Dispatcher) {
        let language = language ?? dispatcher.state.programmingLanguage
        let userId = UserDefaults.standard.integer(forKey: "cc_user_id")
        if dispatcher.state.homeSections["\(language.apiRequestParam)_\(humanLanguage)"]?.value == nil {
            dispatcher.dispatch(Action.loadHomeSections("\(language.apiRequestParam)_\(humanLanguage)", .loading))
        }

        dispatcher.services.challengesService
            .fetchHomeSections(language: language.apiRequestParam, humanLanguage: humanLanguage, id: userId)
            .asResolvable()
            .ephemeralSink { groups in
                dispatcher.dispatch(Action.loadHomeSections("\(language.apiRequestParam)_\(humanLanguage)", groups))
            }
    }
}

struct LoadCollectionContent: ThunkAction {
    let collection: ChallengeCollection

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

struct ChangeProgrammingLanguage: ThunkAction {
    let language: ProgrammingLanguage

    func exec(dispatcher: Dispatcher) {
        dispatcher.dispatch(Action.changeProgrammingLanguage(language))
        UserDefaults.standard.set(language.rawValue, forKey: "programmingLanguage")
    }
}

struct LoadProgrammingLanguage: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        let language = UserDefaults.standard.string(forKey: "programmingLanguage") ?? "python"
        guard let programmingLanguage = ProgrammingLanguage(rawValue: language) else { return }
        dispatcher.dispatch(Action.changeProgrammingLanguage(programmingLanguage))
    }
}

struct LoadRewards: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        dispatcher.dispatch(Action.loadRewards(.pending))
        dispatcher.services.rewardsService
            .loadRewards()
            .asResolvable()
            .ephemeralSink { rewards in
                dispatcher.dispatch(Action.loadRewards(rewards))
            }
    }
}

struct SelectReward: ThunkAction {
    let reward: Reward

    func exec(dispatcher: Dispatcher) {
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session") else { return }
        dispatcher.dispatch(Action.updateLoadingReward(.init(reward: reward, status: .loading)))
        dispatcher.services.rewardsService
            .select(reward: reward, session: session)
            .asResolvable()
            .ephemeralSink { result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dispatcher.dispatch(Action.updateLoadingReward(.init(reward: nil, status: result)))
                    dispatcher.dispatch(LoadAccount())
                }
            }
    }
}

struct FetchConceptReview: ThunkAction {
    let sectionConceptReview: SectionConceptReview

    func exec(dispatcher: Dispatcher) {
        dispatcher.dispatch(Action.loadConceptReview(sectionConceptReview.id, .loading))
        dispatcher.services.conceptReviewService
            .fetchConceptReview(id: "\(sectionConceptReview.id)")
            .asResolvable()
            .ephemeralSink { result in
                dispatcher.dispatch(Action.loadConceptReview(sectionConceptReview.id, result))
            }
    }
}

struct LoadLeaderboardData: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        let id = UserDefaults.standard.integer(forKey: "cc_user_id")
        dispatcher.dispatch(Action.updateLeaderboardData(.loading))

        dispatcher.services
            .leaderboardService
            .getLeaderboardData(id: id)
            .asResolvable()
            .ephemeralSink { result in
                dispatcher.dispatch(Action.updateLeaderboardData(result))
            }
    }
}

struct SendMessageToAI: ThunkAction {
    let message: String
    let mode: ChatMessagesMode

    func exec(dispatcher: Dispatcher) {
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session") else { return }
        let history = dispatcher.state.chatMessages[mode.identifier]?.compactMap { $0.value } ?? []
        dispatcher.dispatch(Action.updateChatMessages(mode: mode, index: nil, message: .success(.init(role: .user, content: message, timestamp: nil))))

        dispatcher.dispatch(Action.updateChatMessages(mode: mode, index: nil, message: .loading))
        let indexOfTheResponseMessage = (dispatcher.state.chatMessages[mode.identifier] ?? []).count - 1

        dispatcher.services.chatService
            .sendMessageToAI(message, history: history, session: session)
            .asResolvable()
            .ephemeralSink { responseMessage in
                dispatcher.dispatch(Action.updateChatMessages(mode: mode, index: indexOfTheResponseMessage, message: responseMessage))
            }
    }
}

struct FetchMaintenanceInfo: ThunkAction {
    func exec(dispatcher: Dispatcher) {
        dispatcher.services
            .authService
            .fetchMaintenance()
            .asResolvable()
            .ephemeralSink { maintenance in
                dispatcher.dispatch(Action.updateMaintenanceInfo(maintenance.value))
            }
    }
}

struct CreateChallengeWithFriend: ThunkAction {
    let programmingLanguage: ProgrammingLanguage
    let difficulty: String

    func exec(dispatcher: Dispatcher) {
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session") else { return }

        dispatcher.dispatch(Action.updateOngoingChallengeFriendData(.loading))
        dispatcher.services.challengeFriendService
            .createChallenge(session: session, difficulty: difficulty, language: programmingLanguage)
            .asResolvable()
            .ephemeralSink { result in
                dispatcher.dispatch(Action.updateOngoingChallengeFriendData(result))
            }
    }
}

struct SendChallengeFriendScore: ThunkAction {
    let score: Int

    func exec(dispatcher: Dispatcher) {
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session"),
              let id = dispatcher.state.ongoingChallengeFriendData.value?.id else { return }

        dispatcher.services.challengeFriendService
            .sendScore(id: id, session: session, score: score)
            .asResolvable()
            .ephemeralSink { result in
                dispatcher.dispatch(Action.updateOngoingChallengeFriendData(result))
                dispatcher.dispatch(LoadAccount())
            }
    }
}

struct AcceptFriendChallenge: ThunkAction {
    let id: Int

    func exec(dispatcher: Dispatcher) {
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session") else { return }

        dispatcher.dispatch(Action.updateOngoingChallengeFriendData(.loading))
        dispatcher.services.challengeFriendService
            .acceptChallenge(id: id, session: session)
            .asResolvable()
            .ephemeralSink { result in
                dispatcher.dispatch(Action.updateOngoingChallengeFriendData(result))
            }
    }
}

struct GetHomeSections: ThunkAction {
    let programmingLanguage: ProgrammingLanguage

    func exec(dispatcher: Dispatcher) {
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session") else { return }

        dispatcher.dispatch(Action.updateLearnSections(programmingLanguage, .loading))
        dispatcher.services.challengesService
            .getLearnSections(programmingLanguage: programmingLanguage, session: session)
            .asResolvable()
            .ephemeralSink { result in
                dispatcher.dispatch(Action.updateLearnSections(programmingLanguage, result))
            }
    }
}

struct UpdateLearningPathProgress: ThunkAction {
    let progress: Int

    func exec(dispatcher: Dispatcher) {
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session") else { return }

//        dispatcher.dispatch(Action.updateLearnSections(programmingLanguage, .loading))
        dispatcher.services.challengesService
            .updatePathProgress(session: session, progress: progress, programmingLanguage: dispatcher.state.programmingLanguage)
            .asResolvable()
            .ephemeralSink { result in
                dispatcher.dispatch(GetHomeSections(programmingLanguage: dispatcher.state.programmingLanguage))
//                dispatcher.dispatch(Action.updateLearnSections(programmingLanguage, result))
            }
    }
}

struct UpdateClassProgress: ThunkAction {
    let progress: Int
    let classId: Int

    func exec(dispatcher: Dispatcher) {
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session") else { return }

//        dispatcher.dispatch(Action.updateLearnSections(programmingLanguage, .loading))
        dispatcher.services.challengesService
            .updateClassProgress(session: session, classId: classId, progress: progress)
            .asResolvable()
            .ephemeralSink { result in
                dispatcher.dispatch(GetLessonCollection(id: classId))
//                dispatcher.dispatch(Action.updateLearnSections(programmingLanguage, result))
            }
    }
}

struct GetLessonCollection: ThunkAction {
    let id: Int

    func exec(dispatcher: Dispatcher) {
        guard let session = UserDefaults.standard.string(forKey: "cc_user_session") else { return }

//        dispatcher.dispatch(Action.updateLessonCollection(id, .loading))
        dispatcher.services.challengesService
            .getLessonCollection(id: id, session: session)
            .asResolvable()
            .ephemeralSink { result in
                dispatcher.dispatch(Action.updateLessonCollection(id, result))
            }
    }
}
