//
//  ConceptReview.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 05/03/2023.
//

import Foundation

struct ConceptReview: Codable {
    let body: [ConceptReviewPage]
}

struct ConceptReviewPage: Codable {
    let title: String
    let components: [ConceptReviewElement]
}

struct ConceptReviewElement: Codable {
    enum `Type`: String, Codable {
        case code
        case note
        case text
        case image
    }

    let type: `Type`
    let value: String
}
