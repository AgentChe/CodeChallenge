//
//  User.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation

struct User: Decodable, Equatable {
    let id: Int
    let session: String?
    let username: String?
    let email: String?
    let photo: String
    let xp: Int
    let isPremium: Bool?
    let streak: Int
    let doneChallangeCount: Int?
}

extension User {
    var isLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
}
