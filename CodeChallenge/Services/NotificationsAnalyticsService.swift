//
//  NotificationsAnalyticsService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/09/2022.
//

import Foundation
import OneSignal
import Paywall
import Mixpanel
import Branch

protocol IdentifyServiceProtocol {
    func identify(id: Int)
    func removeIdentity()
}

struct IdentifyService: IdentifyServiceProtocol {
    func identify(id: Int) {
        OneSignal.setExternalUserId("\(id)")
        Paywall.identify(userId: "\(id)")
        Mixpanel.mainInstance().identify(distinctId: "\(id)")
        Branch.getInstance().setIdentity("\(id)")
        print("TT_identity set_\(id)")
    }

    func removeIdentity() {
        OneSignal.removeExternalUserId()
        Paywall.reset()
        Mixpanel.mainInstance().reset()
    }
}
