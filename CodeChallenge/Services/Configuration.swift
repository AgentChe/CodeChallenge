//
//  Configuration.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 08/10/2022.
//

import Foundation

struct Configuration {
    static var host: String {
        return Self.bundleId == "com.tome.codechallenge" ? "https://api.codehub.ninja" : "https://api.stage.codehub.ninja"
    }

    private static var bundleId: String? {
        Bundle.main.bundleIdentifier
    }
}
