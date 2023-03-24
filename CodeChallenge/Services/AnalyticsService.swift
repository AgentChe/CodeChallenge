//
//  AnalyticsService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 03/09/2022.
//

import Foundation
import Mixpanel
import Paywall

enum AnalyticsEvent {
    case getStarted
    case signUpSelected
    case loginSelected
    case signUpSuccessful
    case loginSuccessful
    case challengeSelected(Challenge, String, ProgrammingLanguage)
    case startedSolving(Challenge, ProgrammingLanguage)
    case challengeCompleted(Int, Bool)
    case browseOpened
    case challengeSearched(String, String)
    case solutionOpened(Challenge, ProgrammingLanguage)
    case paywallOpened
    case planSelected(String)
    case premiumSucceeded(String)
    case viewAllPlansClicked
    case homepageLoaded(Double, Error?)
    case conceptOpened(String)
    case askAICLicked(Int, String)
    case explainMistakeClicked(Int, String)

    var value: String {
        switch self {
        case .getStarted:
            return "Get Started"
        case .signUpSelected:
            return "Sign Up Selected"
        case .loginSelected:
            return "Login Selected"
        case .signUpSuccessful:
            return "Sign Up Successful"
        case .loginSuccessful:
            return "Login Successful"
        case .challengeSelected:
            return "Challenge Selected"
        case .startedSolving:
            return "Started Solving"
        case .challengeCompleted:
            return "Challenge Completed"
        case .browseOpened:
            return "Browse Opened"
        case .challengeSearched:
            return "Challenge Searched"
        case .solutionOpened:
            return "Solution Opened"
        case .paywallOpened:
            return "Paywall Opened"
        case .planSelected:
            return "Plan Selected"
        case .premiumSucceeded:
            return "Premium Succeeded"
        case .viewAllPlansClicked:
            return "View All Plans Clicked"
        case .homepageLoaded:
            return "Homepage Loaded"
        case .conceptOpened:
            return "Concept Opened"
        case .askAICLicked:
            return "Ask AI Clicked"
        case .explainMistakeClicked:
            return "Explain Mistake"
        }
    }

    var properties: [String: MixpanelType] {
        switch self {
        case .challengeSelected(let challenge, let source, let programmingLanguage):
            return [
                "challengeTags": challenge.tagsDescription,
                "challengeId": challenge.id,
                "challengeGroup": programmingLanguage.rawValue,
                "challengeLevel": challenge.progress,
                "source": source]
        case .startedSolving(let challenge, let programmingLanguage):
            return [
                "challengeTags": challenge.tagsDescription,
                "challengeId": challenge.id,
                "challengeGroup": programmingLanguage.rawValue,
                "challengeLevel": challenge.progress]
        case .challengeCompleted(let challenge, let completed):
            return [
                "completedStatus": completed,
                "challengeId": challenge
            ]
        case .challengeSearched(let searchTerm, let type):
            return ["searchTerm": searchTerm, "type": type]
        case .solutionOpened(let challenge, let programmingLanguage):
            return [
                "challengeTags": challenge.tagsDescription,
                "challengeId": challenge.id,
                "challengeGroup": programmingLanguage.rawValue,
                "challengeLevel": challenge.progress]
        case .planSelected(let type):
            return ["type": type]
        case .homepageLoaded(let seconds, let error):
            return ["miliseconds": seconds, "error": error?.localizedDescription ?? ""]
        case .premiumSucceeded(let type):
            return ["type": type]
        case .conceptOpened(let source):
            return ["source": source]
        case .askAICLicked(let id, let buttonName):
            return ["challengeid": "\(id)", buttonName: buttonName]
        case .explainMistakeClicked(let id, let buttonName):
            return ["challengeid": "\(id)", buttonName: buttonName]
        default: return [:]
        }
    }
}

protocol AnalyticsServiceProtocol {
    func track(event: AnalyticsEvent, properties: [String: MixpanelType])
}

struct AnalyticsService: AnalyticsServiceProtocol {
    func track(event: AnalyticsEvent, properties: [String: MixpanelType]) {
        Mixpanel.mainInstance().track(event: event.value, properties: properties)
        Paywall.track(event.value, properties.mapValues { "\($0)" })
    }
}
