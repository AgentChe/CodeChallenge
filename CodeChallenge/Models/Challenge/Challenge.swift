//
//  ChallengeGroups.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation
import UIKit

struct Challenge: Codable {
    struct Tag: Codable, Hashable {
        let name: String
        let color: String
    }
    let id: Int
    let name: String
    let tags: [Tag]
    let difficulty: String
    let isPremium: Bool
    let xp: Int
    let progress: String?
    let isNew: Bool
}

extension Challenge: Equatable {}

extension Challenge {
    var isHard: Bool {
        difficulty.lowercased() == "hard"
    }

    var isMedium: Bool {
        difficulty.lowercased() == "medium"
    }

    var isEasy: Bool {
        difficulty.lowercased() == "easy"
    }

    var allTags: [Tag] {
        [Tag(name: difficulty.lowercased().capitalized, color: difficulty.lowercased().capitalized.toColorHex())] + tags
    }
}

extension Challenge {
    var tagsDescription: String {
        tags.reduce("") { partialResult, result in
            return partialResult + " #\(result.name)"
        }
    }
}

extension String {
    fileprivate func toColorHex() -> String {
        if self == "Easy" {
            return "20BB82"
        } else if self == "Medium" {
            return "FFC169"
        } else if self == "Hard" {
            return "FF7A4F"
        } else {
            return "806FFF"
        }
    }
}
