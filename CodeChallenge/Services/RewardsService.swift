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
    func select(reward: Reward, session: String) -> AnyPublisher<Void, Error>
}

struct RewardsService: RewardsServiceProtocol {
    let networkService: NetworkServiceProtocol

    func loadRewards() -> AnyPublisher<[Reward], Error> {
        return URLRequest
            .create(url: Configuration.host + "/rewards/", type: .get)
            .flatMap { networkService.load($0, decoding: [Reward].self, with: .init()) }
            .eraseToAnyPublisher()
    }

    func select(reward: Reward, session: String) -> AnyPublisher<Void, Error> {
        return URLRequest
            .create(url: Configuration.host + "/rewards/redeem/\(reward.id)/", type: .post)
            .flatMap { networkService.send($0) }
            .eraseToAnyPublisher()
    }
}
