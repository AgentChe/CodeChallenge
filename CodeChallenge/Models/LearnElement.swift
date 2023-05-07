//
//  LearnElement.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/04/2023.
//

import Foundation

struct LearnSections: Decodable {
    let currentProgress: Int
    let contents: [LearnSection]
}

extension LearnSections {
    var allIds: [Int] {
        return contents.reduce([Int](), { partialResult, result in
            partialResult + result.contents.map { $0.id }
        })
    }
    var passedLessonIds: [Int] {
        return allIds.prefix(upTo: (allIds.firstIndex { $0 == currentProgress } ?? 0)).map { $0 }
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
            currentProgress: 0,
            pages: contents.compactMap { $0.challengeId }.enumerated().map { Lesson(id: $0.offset, content: [.challenge($0.element)]) }
        )
    }
}

struct LearnElement: Decodable, Equatable {
    let id: Int
    let title: String
    let progress: CGFloat
    let challengeId: Int?
    let icon: String?
}
