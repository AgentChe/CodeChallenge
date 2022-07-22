//
//  ChallengesService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation
import Combine
import UIKit

protocol ChallengesServiceProtocol {
    func fetchChallengeGroups() -> AnyPublisher<[ChallengeGroup], Error>
}

struct ChallengesService: ChallengesServiceProtocol {
    let networkService: NetworkServiceProtocol

    func fetchChallengeGroups() -> AnyPublisher<[ChallengeGroup], Error> {
        return URLRequest
            .create(url: "https://run.mocky.io/v3/ac8dc76d-cadf-4104-afa0-c27819afaabf", type: .get)
            .flatMap { networkService.load($0, decoding: [ChallengeGroup].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }
}
