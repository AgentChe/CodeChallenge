//
//  NotificationsAnalyticsService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/09/2022.
//

import Foundation
import Branch

protocol IdentifyServiceProtocol {
    func identify(id: Int, subscribed: Bool)
}

struct IdentifyService: IdentifyServiceProtocol {
    func identify(id: Int, subscribed: Bool) {
        Branch.getInstance().setIdentity("\(id)")
    }
}
