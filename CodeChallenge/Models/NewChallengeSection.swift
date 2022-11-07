//
//  NewChallengeGroup.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/11/2022.
//

import Foundation

struct NewChallengeSection: Codable, Equatable {
    var name: String
    var collections: [NewChallengeCollection]
}

struct NewChallengeCollection: Codable, Equatable {
    let id: Int
    let name: String
    let description: String
    let image: String
    let progress: Int
}

struct NewChallengeCollectionContent: Codable, Equatable {
    var id: Int
    var name: String
    var description: String
    var image: String
    var challenges: [Challenge]
}
