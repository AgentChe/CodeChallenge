//
//  ProgrammingLanguage.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 24/12/2022.
//

import Foundation

enum ProgrammingLanguage: String, CaseIterable {
    case python
    case java
    case swift
}

extension ProgrammingLanguage {
    var shortDescription: String {
        switch self {
        case .python:
            return "Challenge yourself with Python coding exercises."
        case .java:
            return "Boost Java skills with interactive coding challenges."
        case .swift:
            return "Enhance Swift skills through interactive coding challenges."
        }
    }
    var description: String {
        switch self {
        case .python:
            return "Begin your coding journey with a fun, all-purpose language, and take the next step in your career."
        case .java:
            return "Practice Java — a robust programming language used to create software, web and mobile apps, and more."
        case .swift:
            return "Swift is a modern programming language developed by Apple. This general-purpose programming language is fast and powerful without sacrificing safety or readability."
        }
    }

    var apiRequestParam: String {
        switch self {
        case .python:
            return "py"
        case .java:
            return "jv"
        case .swift:
            return "sw"
        }
    }

    var openingSymbol: Character {
        switch self {
        case .python:
            return ":"
        case .java, .swift:
            return "{"
        }
    }
}
