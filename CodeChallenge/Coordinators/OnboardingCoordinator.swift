//
//  OnboardingCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 12/06/2023.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import SuperwallKit

class OnboardingCoordinator {
    let navigationController = UINavigationController()
    let store: Store
    private var result: [(OnboardingStep, String)] = []
    private var authCancellable: AnyCancellable?
    
    private let steps: [OnboardingStep] = [
        .init(title: "I want to learn ...", summaryTitle: nil, options: [(image: "python", title: "Python", secondaryTitle: nil), (image: "java", title: "Java", secondaryTitle: nil), (image: "swift", title: "Swift", secondaryTitle: nil)], requestReview: false),
        .init(title: "How much do you already know?", summaryTitle: nil, options: [(image: "onboarding_how_much1", title: "I have no experience", secondaryTitle: nil), (image: "onboarding_how_much2", title: "I have some experience", secondaryTitle: nil), (image: "onboarding_how_much3", title: "I have a lot of experience", secondaryTitle: nil), (image: "onboarding_how_much4", title: "I am a very experienced developer", secondaryTitle: nil)], requestReview: false),
        .init(title: "Why are you learning coding?", summaryTitle: nil, options: [(image: nil, title: "I am studying it at school", secondaryTitle: nil), (image: nil, title: "For a hobby and project in my own time", secondaryTitle: nil), (image: nil, title: "To become a developer", secondaryTitle: nil), (image: nil, title: "Other", secondaryTitle: nil)], requestReview: false),
        .init(title: "Whats your daily learning goal?", summaryTitle: "Learning duration", options: [(image: nil, title: "5 min/day", secondaryTitle: "Casual"), (image: nil, title: "10 min/day", secondaryTitle: "Regular"), (image: nil, title: "15 min/day", secondaryTitle: "Serious"), (image: nil, title: "20 min/day", secondaryTitle: "Intense")], requestReview: false),
        .init(title: "Ready for how many daily practice challenges?", summaryTitle: "Practice", options: [(image: nil, title: "5 challenges", secondaryTitle: "Casual"), (image: nil, title: "10 challenges", secondaryTitle: "Regular"), (image: nil, title: "20 challenges", secondaryTitle: "Serious"), (image: nil, title: "50 challenges", secondaryTitle: "Intense")], requestReview: false),
        .init(title: "How much salary do you want to earn?", summaryTitle: nil, options: [(image: nil, title: "$ 10,000", secondaryTitle: nil), (image: nil, title: "$ 50,000", secondaryTitle: nil), (image: nil, title: "$ 100,000", secondaryTitle: nil), (image: nil, title: "$ 1,000,000", secondaryTitle: nil)], requestReview: true)
    ]
    
    private var currentStep: OnboardingStep?
    
    init(store: Store) {
        self.store = store
        
        let view = OnboardingStarterPage { [weak self] in
            guard let self = self, let first = self.steps.first else { return }
            self.pushToStep(step: first)
        } onLogin: { [weak self] in
            self?.showLogin()
        }
        let controller = UIHostingController(rootView: view)
        navigationController.setViewControllers([controller], animated: false)
    }
    
    func pushToStep(step: OnboardingStep) {
        let view = OnboardingStepView(onNext: { [weak self] option in
            guard let self = self else { return }
            self.result.removeAll(where: {$0.0.title == step.title})
            self.result.append((step, option))
            let stepIndex = self.steps.firstIndex(where: {$0.title == step.title}) ?? 0
            if stepIndex < (self.steps.count - 1) {
                self.pushToStep(step: self.steps[stepIndex + 1])
            } else {
                self.showSummary()
            }
            if step.title == "I want to learn ...", let language = ProgrammingLanguage(rawValue: option.lowercased()) {
                self.store.dispatch(ChangeProgrammingLanguage(language: language))
                self.store.dispatch(LoadRecommendedChallenges())
                self.store.dispatch(GetLearnSections(programmingLanguage: language))
                self.store.dispatch(LoadPracticeSections())
            }
        }, step: step)
        let hostingController = UIHostingController(rootView: view)
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    func showSummary() {
        let view = OnboardingSummaryView(result: result, amount: result.last?.1 ?? "") { [weak self] in
            guard let self = self else { return }
            self.navigationController.dismiss(animated: true)
            
            Superwall.shared.register(event: "get_my_plan", params: [:])
            
            UserDefaults.standard.set(true, forKey: "getStartedPresented")
        }
        let hostingController = UIHostingController(rootView: view)
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    private func showLogin(completion: (() -> Void)? = nil) {
        authCancellable = self.store
            .statePublisher
            .map { $0.user.value?.isLoggedIn }
            .removeDuplicates()
            .sink { [weak self] isLoggedIn in
                guard let self = self else { return }
                if isLoggedIn == true {
                    UserDefaults.standard.set(true, forKey: "getStartedPresented")
                    self.store.dispatch(LoadAccount())
                    self.store.dispatch(LoadInProgressChallenges())
                    self.store.dispatch(LoadCompletedChallenges())
                    self.navigationController.dismiss(animated: true)
                }
            }

        let loginView = LoginView(continuesOperation: false, screenMode: .login, onChangeMode: { [weak self] in
            self?.showSignUpView()
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: loginView)
        navigationController.pushViewController(controller, animated: true)
    }


    func showSignUpView() {
        let loginView = LoginView(screenMode: .signup, onChangeMode: { [weak self] in
            self?.navigationController.popViewController(animated: true)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: loginView)
        navigationController.pushViewController(controller, animated: true)
    }
}
