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
        "some random text for now"
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
