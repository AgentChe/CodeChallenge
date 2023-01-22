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

final class RootCoordinator {
    private let window: UIWindow
    private let store = Store()
    private var authNavigationController: UINavigationController?
    private let accountCoordinator: AccountCoordinator
    private let homeCoordinator: HomeCoordinator
    private let browseCoordinator: BrowseCoordinator
    private let communityCoordinator: CommunityCoordinator
    private let premiumCoordinator: PremiumCoordinator
    private let buddiesCoordinator: BuddiesCoordinator

    private let tabBarController = UITabBarController()
    private var authCancellable: AnyCancellable?
//    private var logoutCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var homePageCancellable: AnyCancellable?

    init(window: UIWindow) {
        self.window = window
        accountCoordinator = AccountCoordinator(store: store)
        homeCoordinator = HomeCoordinator(store: store)
        browseCoordinator = BrowseCoordinator(store: store)
        communityCoordinator = CommunityCoordinator(store: store)
        premiumCoordinator = PremiumCoordinator(store: store)
        buddiesCoordinator = BuddiesCoordinator(store: store)
        setupAppAppearance()
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
            homeCoordinator.navigationController,
            browseCoordinator.navigationController,
            buddiesCoordinator.navigationController,
            premiumCoordinator.navigationController,
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

        if UserDefaults.standard.string(forKey: "cc_user_session") != nil {
            store.dispatch(LoadAccount())
            store.dispatch(LoadInProgressChallenges())
            store.dispatch(LoadCompletedChallenges())
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
        store.dispatch(LoadHomeSections())
        store.dispatch(LoadAppStorePayments())
        store.dispatch(LoadRecommendedChallenges())

        DispatchQueue.global(qos: .userInitiated).async {
            // The first time you create an attributed string of HTML, iOS creates all sorts of extra threads needed to parse the string, among which JavascriptCore engine.
            let data = "<span>html enabled</span>".data(using: .utf8)
            let _ = try! NSAttributedString(data: data!, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        }

        DispatchQueue.main.async { [weak self] in
            let view = HomeLoadingView()
            let controller = UIHostingController(rootView: view)
            controller.modalPresentationStyle = .fullScreen
            self?.window.rootViewController?.present(controller, animated: false)

            let startDate = Date()

            self?.homePageCancellable = self?.store
                .statePublisher
                .compactMap { $0.homeSections["\($0.programmingLanguage.apiRequestParam)_en"] }
                .removeDuplicates()
                .sink { [weak self] result in
                    if let error = result.error {
                        let miliseconds = Date().timeIntervalSince(startDate) * 1000
                        self?.store.dispatch(TrackAnalyticsEvent(event: .homepageLoaded(miliseconds, error)))
                        let alertController = UIAlertController(title: "An error occurred", message: error.localizedDescription, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Retry", style: .default) { action in
                            self?.store.dispatch(LoadHomeSections())
                        }
                        alertController.addAction(action)
                        controller.present(alertController, animated: true)
                    } else if let value = result.value {
                        let miliseconds = Date().timeIntervalSince(startDate) * 1000
                        self?.store.dispatch(TrackAnalyticsEvent(event: .homepageLoaded(miliseconds, nil)))
                        guard let self = self else { return }
                        if !value.isEmpty {
                            self.homePageCancellable?.cancel()
                            self.homePageCancellable = nil
                            controller.dismiss(animated: false)
                        }
                    }
                }
        }
    }

    private func showMaintenanceScreen() {
        let controller = UIHostingController(rootView: MaintenanceView())
        window.rootViewController = controller
    }

    private func showLogin() {
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
//                    self.accountCoordinator.start()
                }
            }

//        logoutCancellable = self.store
//            .statePublisher
//            .map { $0.account.isPending }
//            .removeDuplicates()
//            .sink { [weak self] isLoggedOut in
//                guard let self = self else { return }
//                if isLoggedOut {
//                    self.authNavigationController?.dismiss(animated: true)
//                }
//            }

        let loginView = LoginView(screenMode: .login, onChangeMode: { [weak self] in
            self?.showSignUpView()
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: loginView)
        authNavigationController = UINavigationController(rootViewController: controller)
        if let authNavigationController = authNavigationController {
            UIApplication.shared.windows.first?.rootViewController?.present(authNavigationController, animated: true)
        }
    }


    func showSignUpView() {
        let loginView = LoginView(screenMode: .signup, onChangeMode: { [weak self] in
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
            .map { networkService.load($0, decoding: Maintenance.self, with: .init()) }
            .switchToLatest()
            .asResolvable()
            .compactMap(\.value)
            .map {
                return $0.maintenance
            }
            .eraseToAnyPublisher()
    }
}

struct Maintenance: Codable {
    let maintenance: Bool
}
