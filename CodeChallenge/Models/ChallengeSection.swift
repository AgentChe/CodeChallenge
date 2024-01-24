//
//  NewChallengeGroup.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/11/2022.
//

import Foundation

struct ChallengeSection: Codable, Equatable {
    var name: String
    var collections: [ChallengeCollection]
}

struct SectionConceptReview: Codable, Equatable {
    let id: Int
    let title: String
    let photo: String
}

struct ChallengeCollection: Codable, Equatable {
    let id: Int
    let name: String
    let description: String
    let icon: String
    let isNew: Bool
    let conceptReview: SectionConceptReview?

    enum CodingKeys: CodingKey {
        case id
        case name
        case description
        case icon
        case isNew
        case conceptReview
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description).removingPercentEncoding ?? ""
        self.icon = try container.decode(String.self, forKey: .icon)
        self.isNew = try container.decode(Bool.self, forKey: .isNew)
        self.conceptReview = try container.decodeIfPresent(SectionConceptReview.self, forKey: .conceptReview)
    }

    init(id: Int, name: String = "random", description: String = "random 2", icon: String = "just", isNew: Bool = false, conceptReview: SectionConceptReview? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.isNew = isNew
        self.conceptReview = conceptReview
    }
}

struct IdProgressCouple: Codable {
    let id: Int
    let progress: Double
}

struct ChallengeCollectionContent: Codable, Equatable {
    var id: Int
    var name: String
    var description: String
    var icon: String
    var challenges: [Challenge]

    enum CodingKeys: CodingKey {
        case id
        case name
        case description
        case icon
        case challenges
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description).removingPercentEncoding ?? ""
        self.icon = try container.decode(String.self, forKey: .icon)
        self.challenges = try container.decode([Challenge].self, forKey: .challenges)
    }
}

struct ChallengeCollectionContentProgress: Codable {
    var id: Int
    var progress: Double
    var challenges: [IdProgressStringCouple]
}

struct IdProgressStringCouple: Codable {
    let id: String
    let progress: String
}
