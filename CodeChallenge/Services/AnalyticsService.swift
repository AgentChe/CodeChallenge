//
//  AnalyticsService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 03/09/2022.
//

import Foundation
import Mixpanel
import OneSignal

enum AnalyticsEvent {
    case getStarted
    case signUpSelected
    case loginSelected
    case signUpSuccessful
    case loginSuccessful
    case challengeSelected(Challenge, ChallengeGroup?, String)
    case startedSolving(Challenge, ChallengeGroup?)
    case challengeCompleted(Challenge, Bool)
    case browseOpened
    case challengeSearched(String, String)
    case solutionOpened(Challenge, ChallengeGroup?)
    case paywallOpened
    case planSelected(String)
    case pricingOpened
    case homepageLoaded(Double, Error?)

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
        case .pricingOpened:
            return "Pricing Opened"
        case .homepageLoaded:
            return "Homepage Loaded"
        }
    }

    var properties: [String: MixpanelType] {
        switch self {
        case .challengeSelected(let challenge, let group, let source):
            return [
                "challengeTags": challenge.tagsDescription,
                "challengeId": challenge.id,
                "challengeGroup": group?.name ?? "",
                "challengeLevel": challenge.progress,
                "source": source]
        case .startedSolving(let challenge, let group):
            return [
                "challengeTags": challenge.tagsDescription,
                "challengeId": challenge.id,
                "challengeGroup": group?.name ?? "",
                "challengeLevel": challenge.progress]
        case .challengeCompleted(let challenge, let completed):
            return [
                "completedStatus": completed,
                "challengeTags": challenge.tagsDescription,
                "challengeId": challenge.id,
                "challengeLevel": challenge.progress
            ]
        case .challengeSearched(let searchTerm, let type):
            return ["searchTerm": searchTerm, "type": type]
        case .solutionOpened(let challenge, let group):
            return [
                "challengeTags": challenge.tagsDescription,
                "challengeId": challenge.id,
                "challengeGroup": group?.name ?? "",
                "challengeLevel": challenge.progress]
        case .planSelected(let type):
            return ["type": type]
        case .homepageLoaded(let seconds, let error):
            return ["miliseconds": seconds, "error": error?.localizedDescription ?? ""]
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
    }
}
