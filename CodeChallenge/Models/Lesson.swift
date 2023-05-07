//
//  Lesson.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 03/04/2023.
//

import Foundation

struct LessonCollection: Decodable {
    let id: Int
    let currentProgress: Int
    let pages: [Lesson]
}

struct Lesson: Decodable, Equatable {
    let id: Int
    let content: [LessonContent]
}

extension LessonCollection {
    var enabledPages: [Lesson] {
        getEnabledPages(basedOn: currentProgress)
    }

    func getEnabledPages(basedOn progress: Int) -> [Lesson] {
        let index = pages.firstIndex(where: { lesson in
            lesson.id == progress
        })
        guard let index = index else { return [pages.first].compactMap { $0 } }
        if index == pages.count - 1 {
            return pages
        }
        return pages[0..<(index + 2)].map { $0 }
    }
}

enum LessonContent: Decodable, Equatable {
    case heading(String)
    case text(String)
    case image(String)
    case code(String, String)
    case chooseAnswerQuiz(String, [String], [String])
    case composeCodeQuiz(String, [String], [String])
    case challenge(Int)
    case unknown

    enum CodingKeys: CodingKey {
        case text
        case image
        case code
        case pl
        case options
        case winning
        case id
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "heading":
            self = LessonContent.heading(try container.decode(String.self, forKey: CodingKeys.text))
        case "text":
            self = LessonContent.text(try container.decode(String.self, forKey: CodingKeys.text))
        case "image":
            self = LessonContent.image(try container.decode(String.self, forKey: CodingKeys.image))
        case "code":
            self = LessonContent.code(try container.decode(String.self, forKey: CodingKeys.code),
                                      try container.decode(String.self, forKey: CodingKeys.pl))
        case "chooseAnswerQuiz":
            self = LessonContent.chooseAnswerQuiz(try container.decode(String.self, forKey: CodingKeys.text),
                                                  try container.decode([String].self, forKey: CodingKeys.options),
                                                  try container.decode([String].self, forKey: CodingKeys.winning))
        case "composeCodeQuiz":
            self = LessonContent.composeCodeQuiz(try container.decode(String.self, forKey: CodingKeys.text),
                                                 try container.decode([String].self, forKey: CodingKeys.options),
                                                 try container.decode([String].self, forKey: CodingKeys.winning))
        case "challenge":
            self = LessonContent.challenge(try container.decode(Int.self, forKey: CodingKeys.id))
        default: self = .unknown
        }
    }
}
