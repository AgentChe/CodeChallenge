//
//  RewardsService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 20/02/2023.
//

import Foundation
import Combine

protocol RewardsServiceProtocol {
    func loadRewards() -> AnyPublisher<[Reward], Error>
    func select(reward: Reward) -> AnyPublisher<Void, Error>
}

struct RewardsService: RewardsServiceProtocol {
    let networkService: NetworkServiceProtocol

    func loadRewards() -> AnyPublisher<[Reward], Error> {
        return URLRequest
            .create(url: "https://run.mocky.io/v3/c7f131dc-7a6c-4639-9662-d662ade19df9", type: .get)
            .flatMap { networkService.load($0, decoding: [Reward].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func select(reward: Reward) -> AnyPublisher<Void, Error> {
//        return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
