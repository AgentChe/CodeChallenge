//
//  Rewards.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 20/02/2023.
//

import Foundation

struct Reward: Codable {
    let id: Int
    let title: String
    let description: String
    let xp: Int
}

struct LoadingReward {
    let reward: Reward?
    let status: Resolvable<()>
}

extension Reward {
    var imageURL: String {
        return Configuration.host + "/rewards/getImage/\(id)/"
    }
}
