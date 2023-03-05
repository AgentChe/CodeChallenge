//
//  ConceptReviewService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 05/03/2023.
//

import Foundation
import Combine

protocol ConceptReviewServiceProtocol {
    func fetchConceptReview(id: String) -> AnyPublisher<ConceptReview, Error>
}

struct ConceptReviewService: ConceptReviewServiceProtocol {
    let networkService: NetworkServiceProtocol

    func fetchConceptReview(id: String) -> AnyPublisher<ConceptReview, Error> {
        return URLRequest
            .create(url: Configuration.host + "/concept_review/\(id)", type: .get)
            .flatMap { networkService.load($0, decoding: ConceptReview.self, with: .init()) }
            .eraseToAnyPublisher()
    }
}
