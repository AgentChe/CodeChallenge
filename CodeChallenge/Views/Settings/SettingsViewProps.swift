//
//  SettingsViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 03/09/2022.
//

import Foundation

protocol SettingsViewProps {
    var store: Store { get }
}

extension SettingsViewProps {
    var userExists: Bool {
        UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
}
