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
            .create(url: "https://run.mocky.io/v3/543d1443-fa59-4960-ac93-747a8f0ebf8c", type: .get)
            .flatMap { networkService.load($0, decoding: [Reward].self, with: .init()) }
            .eraseToAnyPublisher()
    }

    func select(reward: Reward) -> AnyPublisher<Void, Error> {
//        return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
