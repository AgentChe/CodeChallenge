//
//  HomeElement.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/04/2023.
//

import Foundation

struct LearnSections: Codable {
    let currentProgress: Int
    let contents: [HomeSection]
}

struct HomeSection: Codable {
    let title: String
    let contents: [HomeElement]
}

struct HomeElement: Codable, Hashable {
    let id: Int
    let title: String
    let icon: String?
}
