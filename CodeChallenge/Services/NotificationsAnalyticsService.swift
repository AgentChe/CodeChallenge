//
//  NotificationsAnalyticsService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/09/2022.
//

import Foundation
import OneSignal
import Mixpanel
import Branch
import SuperwallKit

protocol IdentifyServiceProtocol {
    func identify(id: Int, subscribed: Bool)
    func removeIdentity()
}

struct IdentifyService: IdentifyServiceProtocol {
    func identify(id: Int, subscribed: Bool) {
        OneSignal.setExternalUserId("\(id)")
        Superwall.shared.identify(userId: "\(id)")
        Mixpanel.mainInstance().identify(distinctId: "\(id)")
        Branch.getInstance().setIdentity("\(id)")
        Superwall.shared.setUserAttributes(["subscribed": subscribed])
    }

    func removeIdentity() {
        OneSignal.removeExternalUserId()
        Superwall.shared.reset()
        Mixpanel.mainInstance().reset()
    }
}
