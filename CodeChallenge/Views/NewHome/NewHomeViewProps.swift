//
//  NewHomeViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/11/2022.
//

import Foundation

protocol NewHomeViewProps {
    var store: Store { get }
    var language: String { get }
    var humanLanguage: String { get }
}

extension NewHomeViewProps {
    var isLoading: Bool {
        store.state.homeSections[identifier]?.isLoading == true
    }

    var sections: [NewChallengeSection]? {
        store.state.homeSections[identifier]?.value
    }

    var identifier: String {
        "\(language)_\(humanLanguage)"
    }
}
