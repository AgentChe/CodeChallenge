//
//  RootCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import Paywall

final class RootCoordinator {
    private let window: UIWindow
    internal let store = Store()
    private var authNavigationController: UINavigationController?
    private let accountCoordinator: AccountCoordinator
    private let practiceCoordinator: PracticeCoordinator
    private let learnCoordinator: LearnCoordinator
    private let browseCoordinator: LeaderboardCoordinator
    private let buddiesCoordinator: BuddiesCoordinator

    private let tabBarController = UITabBarController()
    private var authCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var practicePageCancellable: AnyCancellable?
    private var accountCancellable: AnyCancellable?
    private var challengeFriendCancellable: AnyCancellable?
    var challengeFriendNavigationController: UINavigationController?

    private let paywallService: PaywallService

    init(window: UIWindow) {
        self.window = window
        accountCoordinator = AccountCoordinator(store: store)
        practiceCoordinator = PracticeCoordinator(store: store)
        browseCoordinator = LeaderboardCoordinator(store: store)
        buddiesCoordinator = BuddiesCoordinator(store: store)
        learnCoordinator = LearnCoordinator(store: store)
        paywallService = PaywallService(store: store)
        setupAppAppearance()
        practiceCoordinator.onEndingOnboarding = { [weak self] in
            let challengeFriendId = UserDefaults.standard.integer(forKey: "challenge_friend_key")
            guard challengeFriendId != 0 else { return }
            self?.process(challengeFriendId: challengeFriendId)
        }
    }

    func start() {
        if !UserDefaults.standard.bool(forKey: "isLoggedIn") {
            store.dispatch(GuestAuth())
        } else {
            store.dispatch(LoadAccount())
            store.dispatch(LoadInProgressChallenges())
            store.dispatch(LoadCompletedChallenges())
        }
        let tabs = [
            learnCoordinator.navigationController,
            practiceCoordinator.navigationController,
            browseCoordinator.navigationController,
            buddiesCoordinator.navigationController,
            accountCoordinator.navigationController
        ]
        tabBarController.setViewControllers(tabs, animated: false)
        tabBarController.tabBar.items?.forEach {
            $0.image = $0.image?.withRenderingMode(.alwaysOriginal)
        }
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.tabbar], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.CodeChallenge.blue1], for: .selected)
        window.rootViewController = tabBarController
        accountCoordinator.onLogin = { [weak self] in
            self?.showLogin()
        }

        buddiesCoordinator.onLogin = { [weak self] action in
            self?.showLogin(action: action)
        }

        learnCoordinator.onClaimCertificate = { [weak self] isLoggedIn in
            let runAlert = {
                let alertController = UIAlertController(title: "Certificate claimed!", message: "You'll be notified via an email in 48 hours", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default) { _ in }
                alertController.addAction(action)
                self?.learnCoordinator.navigationController.present(alertController, animated: true)
            }
            if isLoggedIn {
                self?.store.dispatch(TrackAnalyticsEvent(event: .claimCertificate))
                runAlert()
            } else {
                self?.showLogin(action: TrackAnalyticsEvent(event: .claimCertificate), completion: runAlert)
            }
        }

        accountCoordinator.onGoPremium = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tabBarController.selectedIndex = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.practiceCoordinator.presentPremiumScreen(from: self.practiceCoordinator.navigationController)
                }
            }
        }
        practiceCoordinator.onGoPremium = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tabBarController.selectedIndex = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.practiceCoordinator.presentPremiumScreen(from: self.practiceCoordinator.navigationController)
                }
            }
        }

        store.dispatch(AddStreakIfNeeded())

        isAppVersionSupported(store.services.networkService)
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.showForceUpdateAlert()
            }
            .store(in: &cancellables)

        isAppMaintained(store.services.networkService)
            .filter { $0 }
            .sink { [weak self] _ in
                self?.showMaintenanceScreen()
            }
            .store(in: &cancellables)

        store.dispatch(LoadProgrammingLanguage())
        store.dispatch(LoadPracticeSections())
        store.dispatch(LoadAppStorePayments())
        store.dispatch(LoadRecommendedChallenges())
        store.dispatch(LoadRewards())
        store.dispatch(FetchMaintenanceInfo())

        DispatchQueue.global(qos: .userInitiated).async {
            // The first time you create an attributed string of HTML, iOS creates all sorts of extra threads needed to parse the string, among which JavascriptCore engine.
            let data = "<span>html enabled</span>".data(using: .utf8)
            let _ = try! NSAttributedString(data: data!, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        }

        DispatchQueue.main.async { [weak self] in
            let startDate = Date()

            self?.practicePageCancellable = self?.store
                .statePublisher
                .compactMap { $0.practiceSections["\($0.programmingLanguage.apiRequestParam)_en"] }
                .removeDuplicates()
                .sink { [weak self] result in
                    if let error = result.error {
                        let miliseconds = Date().timeIntervalSince(startDate) * 1000
                        self?.store.dispatch(TrackAnalyticsEvent(event: .practicepageLoaded(miliseconds, error)))
                        let alertController = UIAlertController(title: "An error occurred", message: error.localizedDescription, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Retry", style: .default) { action in
                            self?.store.dispatch(LoadPracticeSections())
                        }
                        alertController.addAction(action)
                        self?.learnCoordinator.navigationController.present(alertController, animated: true)
                    } else if let value = result.value {
                        let miliseconds = Date().timeIntervalSince(startDate) * 1000
                        self?.store.dispatch(TrackAnalyticsEvent(event: .practicepageLoaded(miliseconds, nil)))
                        guard let self = self else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            if !value.isEmpty {
                                self.practicePageCancellable?.cancel()
                                self.practicePageCancellable = nil
                            }
                        }
                    }
                }
        }
    }

    private func showMaintenanceScreen() {
        let controller = UIHostingController(rootView: MaintenanceView())
        window.rootViewController = controller
    }

    private func showLogin(action: ThunkAction? = nil, completion: (() -> Void)? = nil) {
        authCancellable = self.store
            .statePublisher
            .map { $0.user.value?.isLoggedIn }
            .removeDuplicates()
            .sink { [weak self] isLoggedIn in
                guard let self = self else { return }
                if isLoggedIn == true {
                    self.store.dispatch(LoadAccount())
                    self.store.dispatch(LoadInProgressChallenges())
                    self.store.dispatch(LoadCompletedChallenges())
                    self.authNavigationController?.dismiss(animated: true)
                    if let action = action {
                        self.store.dispatch(action)
                        completion?()
                    }
                }
            }

        let loginView = LoginView(continuesOperation: action != nil, screenMode: .login, onChangeMode: { [weak self] in
            self?.showSignUpView(continuesOperation: action != nil)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: loginView)
        authNavigationController = UINavigationController(rootViewController: controller)
        if let authNavigationController = authNavigationController {
            UIApplication.shared.mainWindow?.rootViewController?.present(authNavigationController, animated: true)
        }
    }


    func showSignUpView(continuesOperation: Bool) {
        let loginView = LoginView(continuesOperation: continuesOperation, screenMode: .signup, onChangeMode: { [weak self] in
            self?.authNavigationController?.popViewController(animated: true)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: loginView)
        authNavigationController?.pushViewController(controller, animated: true)
    }
}

extension RootCoordinator {
    private func setupAppAppearance() {
        window.backgroundColor = .CodeChallenge.dark
        window.overrideUserInterfaceStyle = .light

        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.backgroundColor = .CodeChallenge.tabBar
        tabBarAppearance.barTintColor = .CodeChallenge.tabBar
        tabBarAppearance.isTranslucent = false

        tabBarAppearance.contentMode = .scaleToFill

        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()
        barAppearance.backgroundImage = .init()
        barAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        barAppearance.backButtonAppearance.normal.accessibilityLabel = "navigation back"
        barAppearance.backgroundColor = .clear
        barAppearance.shadowColor = UIColor.clear
        barAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.CodeChallenge.white,
                                                  .font: UIFont.systemFont(ofSize: 48)]
        barAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.CodeChallenge.white,
            .font: UIFont.systemFont(ofSize: 20)
        ]
        barAppearance.setBackIndicatorImage(.init(named: "back"), transitionMaskImage: .init(named: "back"))
        UINavigationBar.appearance().compactAppearance = barAppearance
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().isOpaque = false
    }
}

extension RootCoordinator {
    func isAppVersionSupported(_ networkService: NetworkServiceProtocol) -> AnyPublisher<Bool, Never> {
        guard
            let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let appVersion = Double(versionString)
        else {
            return Just(true).eraseToAnyPublisher()
        }
        let versionsURL = "https://api.codehub.ninja/version/"
        return
            URLRequest.create(url: versionsURL)
            .map {
                var copy = $0
                copy.cachePolicy = .reloadIgnoringCacheData
                return copy
            }
            .map { networkService.load($0, decoding: String.self, with: .init()) }
            .switchToLatest()
            .asResolvable()
            .compactMap(\.value)
            .map {
                Double($0) ?? 0 <= appVersion
            }
            .eraseToAnyPublisher()
    }

    private func showForceUpdateAlert() {
        let alert = UIAlertController(
            title: "Unsupported Version",
            message: "This version of Codehub is no longer supported. Please update the app from the App Store",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
            guard
                let url = URL(string: "itms-apps://itunes.apple.com/app/1632477791")
            else { return }
            UIApplication.shared.open(url)
            self?.showForceUpdateAlert()
        }
        alert.addAction(action)
        window.rootViewController?.present(alert, animated: true)
    }
}

extension RootCoordinator {
    func isAppMaintained(_ networkService: NetworkServiceProtocol) -> AnyPublisher<Bool, Never> {
        let url = "https://maintenance.yervandgaloyan.workers.dev/"
        return
            URLRequest.create(url: url)
            .map {
                var copy = $0
                copy.cachePolicy = .reloadIgnoringCacheData
                return copy
            }
            .map { networkService.load($0, decoding: Maintenance.self, with: .snakeCase) }
            .switchToLatest()
            .asResolvable()
            .compactMap(\.value)
            .map {
                return $0.maintenance
            }
            .eraseToAnyPublisher()
    }
}

extension RootCoordinator {
    func isPremiumEnabled(_ networkService: NetworkServiceProtocol) -> AnyPublisher<Bool, Never> {
        let url = "https://maintenance.yervandgaloyan.workers.dev/"
        return
            URLRequest.create(url: url)
            .map {
                var copy = $0
                copy.cachePolicy = .reloadIgnoringCacheData
                return copy
            }
            .map { networkService.load($0, decoding: Maintenance.self, with: .init()) }
            .switchToLatest()
            .asResolvable()
            .compactMap(\.value)
            .map {
                return $0.premium
            }
            .eraseToAnyPublisher()
    }
}

extension RootCoordinator {
    func process(challengeFriendId: Int) {
        guard store.state.ongoingChallengeFriendData.isPending else { return }
        accountCancellable =
        store.statePublisher
            .filter { $0.account.value != nil && $0.practiceSections != [:] }
            .sink(receiveValue: { [weak self] _ in
                guard self?.store.state.ongoingChallengeFriendData.isPending == true else { return }
                self?.store.dispatch(AcceptFriendChallenge(id: challengeFriendId))

                self?.challengeFriendCancellable =
                self?.store.statePublisher
                    .map { $0.ongoingChallengeFriendData }
                    .sink(receiveValue: { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .failure:
                            self.store.dispatch(Action.updateOngoingChallengeFriendData(.pending))
                            self.presentFailure(navigationController: self.learnCoordinator.navigationController)
                            self.challengeFriendCancellable?.cancel()
                            self.challengeFriendCancellable = nil
                            self.accountCancellable?.cancel()
                            self.accountCancellable = nil
                        case .success(let challengeFriendData):
                            guard !challengeFriendData.expired else { return }

                            DispatchQueue.main.async {
                                self.startChallengeFriend(with: challengeFriendData, from: self.learnCoordinator.navigationController)
                                self.challengeFriendCancellable?.cancel()
                                self.challengeFriendCancellable = nil
                                self.accountCancellable?.cancel()
                                self.accountCancellable = nil
                            }
                        default: break
                        }
                    })
            })
    }

    private func presentFailure(navigationController: UINavigationController) {
        let alertController = UIAlertController(title: "Could not load the challenge", message: "The challenge you're trying to solve does not exist or is expired", preferredStyle: .alert)
        alertController.addAction(.init(title: "Ok", style: .default))
        navigationController.present(alertController, animated: true)
    }
}

extension RootCoordinator: ChallengeFriendPresentable {}
