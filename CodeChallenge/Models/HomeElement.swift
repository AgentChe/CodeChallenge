//
//  HomeElement.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/04/2023.
//

import Foundation

struct LearnSections: Decodable {
    let currentProgress: Int
    let contents: [HomeSection]
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

struct HomeSection: Decodable, Equatable {
    let title: String
    let description: String
    let contents: [HomeElement]
}

struct HomeElement: Decodable, Equatable {
    let id: Int
    let title: String
    let pages: [Lesson]
    let icon: String?
}

extension HomeElement {
    var allIds: [Int] {
        return pages.reduce([Int](), { partialResult, result in
            partialResult + [result.id]
        })
    }
    var passedIds: [Int] {
        return allIds.prefix(upTo: (allIds.firstIndex { $0 == 9 } ?? 0)).map { $0 }
    }
}
