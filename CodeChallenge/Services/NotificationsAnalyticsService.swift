//
//  NotificationsAnalyticsService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/09/2022.
//

import Foundation
import Branch
import SuperwallKit

protocol IdentifyServiceProtocol {
    func identify(id: Int, subscribed: Bool)
    func removeIdentity()
}

struct IdentifyService: IdentifyServiceProtocol {
    func identify(id: Int, subscribed: Bool) {
        Superwall.shared.identify(userId: "\(id)")
        Branch.getInstance().setIdentity("\(id)")
        Superwall.shared.setUserAttributes(["subscribed": subscribed])
    }

    func removeIdentity() {
        Superwall.shared.reset()
    }
}
