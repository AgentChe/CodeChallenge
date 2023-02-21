//
//  Rewards.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 20/02/2023.
//

import Foundation

struct Reward: Codable {
    let name: String
}

struct LoadingReward {
    let reward: Reward?
    let status: Resolvable<()>
}
