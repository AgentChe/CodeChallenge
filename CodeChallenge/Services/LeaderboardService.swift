//
//  LeaderboardService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/03/2023.
//

import Foundation
import Combine

protocol LeaderboardServiceProtocol {
    func getLeaderboardData(id: Int) -> AnyPublisher<LeaderboardData, Error>
}

struct LeaderboardService: LeaderboardServiceProtocol {
    let networkService: NetworkServiceProtocol

    func getLeaderboardData(id: Int) -> AnyPublisher<LeaderboardData, Error> {
        return URLRequest
            .create(url: Configuration.host + "/leaderboard/\(id)/", type: .get)
            .flatMap { networkService.load($0, decoding: LeaderboardData.self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }
}
