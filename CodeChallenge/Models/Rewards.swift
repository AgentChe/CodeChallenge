//
//  Rewards.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 20/02/2023.
//

import Foundation

struct Reward: Codable {
    let id: Int
    let name: String
    let imageURL: String
    let xp: Int
}

struct LoadingReward {
    let reward: Reward?
    let status: Resolvable<()>
}
