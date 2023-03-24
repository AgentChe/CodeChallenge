//
//  ChallengeFriend.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 18/03/2023.
//

import Foundation

struct ChallengeFriendData: Codable {
    struct Scores: Codable {
        let fromUser: Int
        let toUser: Int
    }
    let id: Int
    let difficulty: String
    let programmingLanguage: String
    let challenges: [Int]
    let scores: Scores
    let winner: Int
    let expired: Bool
    let fromUser: Int
}
