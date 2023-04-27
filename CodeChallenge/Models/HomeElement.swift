//
//  HomeElement.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/04/2023.
//

import Foundation

struct LearnSections: Codable {
    let pl: String
    let contents: [HomeSection]
}

struct HomeSection: Codable {
    let title: String
    let id: Int
    let contents: [HomeElement]
}

struct HomeElement: Codable, Hashable {
    enum State: String, Codable {
        case done
        case blocked
        case jumped
        case todo
    }
    let id: Int
    let title: String
    let icon: String
    let state: State
}
