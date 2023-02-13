//
//  ChallengeProgress.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 14/02/2023.
//

import Foundation

struct ChallengeProgress: Codable {
    struct Solution: Codable {
        let python: String
    }
    let id: Int?
    let dateCreated, dateModified: Double?
    let challengeId: Int?
    let userId: Int?
    let type: String?
    let progress: CGFloat?
    let solution: Solution?
    let spentTime: Int?
}
