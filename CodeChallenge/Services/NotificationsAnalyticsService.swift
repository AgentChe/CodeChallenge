//
//  NotificationsAnalyticsService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/09/2022.
//

import Foundation
import OneSignal

protocol NotificationsAnalyticsServiceProtocol {
    func identify(id: Int)
    func removeIdentity()
    func track(event: AnalyticsEvent, properties: [String: String])
}

struct NotificationsAnalyticsService: NotificationsAnalyticsServiceProtocol {
    func identify(id: Int) {
        OneSignal.setExternalUserId("\(id)")
    }

    func removeIdentity() {
        OneSignal.removeExternalUserId()
    }

    func track(event: AnalyticsEvent, properties: [String: String]) {
        
    }
}
