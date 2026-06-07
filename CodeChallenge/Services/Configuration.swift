//
//  Configuration.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 08/10/2022.
//

import Foundation

struct Configuration {
    static var host: String {
        "https://codehub.thinkaboutapps.com"
    }

    private static var bundleId: String? {
        Bundle.main.bundleIdentifier
    }
}
