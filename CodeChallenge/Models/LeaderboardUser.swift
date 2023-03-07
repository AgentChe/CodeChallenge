//
//  LeaderboardUser.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/03/2023.
//

import Foundation

struct LeaderboardUser: Codable, Equatable, Identifiable {
    let id: Int
    let username: String?
    let photo: String
    let xp: Int
    let isPremium: Bool
}

struct LeaderboardData: Codable, Equatable {
    let topUsers: [LeaderboardUser]
    let userNeighbors: [LeaderboardUser]
}
