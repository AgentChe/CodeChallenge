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
}

extension ProgrammingLanguage {
    var description: String {
        switch self {
        case .python:
            return "Begin your coding journey with a fun, all-purpose language, and take the next step in your career."
        case .java:
            return "Practice Java — a robust programming language used to create software, web and mobile apps, and more."
        }
    }

    var apiRequestParam: String {
        switch self {
        case .python:
            return "py"
        case .java:
            return "jv"
        }
    }

    var openingSymbol: Character {
        switch self {
        case .python:
            return ":"
        case .java:
            return "{"
        }
    }
}
