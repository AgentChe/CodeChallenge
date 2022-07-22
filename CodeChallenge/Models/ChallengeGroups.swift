//
//  ChallengeGroups.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation

struct ChallengeGroup: Codable {
    let name: String
    let icon: String
    let description: String
    let challenges: [Challenge]
}

struct Challenge: Codable {
    let challangeId: Int
    let name: String
    let body: String
    let icon: String
    let tags: [String]
    let level: String
}
