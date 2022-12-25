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
    var icon: String {
        "language_image"
    }

    var description: String {
        "some random text for now"
    }

    var apiRequestParam: String {
        switch self {
        case .python:
            return "py"
        case .java:
            return "java"
        }
    }
}
