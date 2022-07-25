//
//  AutocompleteTermsHelper.swift
//  CC
//
//  Created by Tatevik Tovmasyan on 26/05/2022.
//

import Foundation

struct AutocompleteTermsHelper {
    static var terms: [String: [String]]? {
        if let path = Bundle.main.path(forResource: "AutocompleteList", ofType: "plist"),
        let xml = FileManager.default.contents(atPath: path) {
            return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String: [String]]
        }
        return [:]
    }

    static func getMatches(string: String) -> [String] {
        if let pythonTerms = terms?["python"] {
            return pythonTerms.filter { $0.lowercased().starts(with: string.lowercased()) }
        }
        return []
    }
}
