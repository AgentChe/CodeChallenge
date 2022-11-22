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
    let icon: String
    let progress: Int
    let isNew: Bool

    enum CodingKeys: CodingKey {
        case id
        case name
        case description
        case icon
        case progress
        case isNew
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description).removingPercentEncoding ?? ""
        self.icon = try container.decode(String.self, forKey: .icon)
        self.progress = try container.decode(Int.self, forKey: .progress)
        self.isNew = try container.decode(Bool.self, forKey: .isNew)
    }

    init(id: Int, name: String = "random", description: String = "random 2", icon: String = "just", progress: Int = 0, isNew: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.progress = progress
        self.isNew = isNew
    }
}

struct NewChallengeCollectionContent: Codable, Equatable {
    var id: Int
    var name: String
    var description: String
    var icon: String
    var challenges: [Challenge]
    let progress: Int

    enum CodingKeys: CodingKey {
        case id
        case name
        case description
        case icon
        case challenges
        case progress
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description).removingPercentEncoding ?? ""
        self.icon = try container.decode(String.self, forKey: .icon)
        self.challenges = try container.decode([Challenge].self, forKey: .challenges)
        self.progress = try container.decode(Int.self, forKey: .progress)
    }
}
