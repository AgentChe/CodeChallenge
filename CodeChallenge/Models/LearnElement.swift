//
//  LearnElement.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/04/2023.
//

import Foundation

struct LearnSections: Decodable {
    let contents: [LearnSection]
}

struct LearnSectionsProgress: Decodable {
    let currentProgress: Int
    let contents: [LearnSectionProgress]
}

struct LearnSectionProgress: Codable {
    let contents: [IdProgressCouple]
}

extension LearnSectionsProgress {
    var allIds: [Int] {
        return contents.reduce([Int](), { partialResult, result in
            partialResult + result.contents.map { $0.id }
        })
    }
    var lastSectionIsDone: Bool {
        contents.last?.contents.last?.progress == 100
    }
    var passedLessonIds: [Int] {
        let passedIds = allIds.prefix(upTo: (allIds.firstIndex { $0 == currentProgress } ?? 0)).map { $0 }
        return passedIds + (lastSectionIsDone ? [allIds.last].compactMap { $0 } : [])
    }
}

struct LearnSection: Decodable, Equatable {
    let title: String
    let description: String
    let contents: [LearnElement]
}

extension LearnSection {
    var lessonCollection: LessonCollection {
        return LessonCollection(
            id: contents.last?.id ?? 0,
            pages: contents.compactMap { $0.challengeId }.enumerated().map { Lesson(id: $0.offset + 1, content: [.challenge($0.element)]) }
        )
    }
}

struct LearnElement: Decodable, Equatable {
    let id: Int
    let isPremium: Bool?
    let title: String
    let challengeId: Int?
    let icon: String?
}
