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
            return "Explore the language behind most of data science"
        case .java:
            return "Explore the language legends been coding"
        case .swift:
            return "Explore the iOS world"
        }
    }
    var description: String {
        switch self {
        case .python:
            return "Begin your coding journey with a fun, all-purpose language, and take the next step in your career."
        case .java:
            return "Practice Java — a robust programming language used to create software, web and mobile apps, and more."
        case .swift:
            return "Practice Swift - amenatuyn lezun"
        }
    }

    var apiRequestParam: String {
        switch self {
        case .python:
            return "py"
        case .java:
            return "jv"
        case .swift:
            return "swift"
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
