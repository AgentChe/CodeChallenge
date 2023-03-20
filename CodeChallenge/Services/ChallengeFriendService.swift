//
//  ChallengeFriendService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 18/03/2023.
//

import Foundation
import Combine

protocol ChallengeFriendServiceProtocol {
    func createChallenge(session: String, difficulty: String, language: ProgrammingLanguage) -> AnyPublisher<ChallengeFriendData, Error>
    func acceptChallenge(id: Int, session: String) -> AnyPublisher<ChallengeFriendData, Error>
    func sendScore(id: Int, session: String, score: Int) -> AnyPublisher<ChallengeFriendData, Error>
}

struct ChallengeFriendService: ChallengeFriendServiceProtocol {
    let networkService: NetworkServiceProtocol

    func createChallenge(session: String, difficulty: String, language: ProgrammingLanguage) -> AnyPublisher<ChallengeFriendData, Error> {
        let body = ["session": session, "difficulty": difficulty, "pl": language.apiRequestParam]
        return URLRequest
            .create(url: Configuration.host + "/challenge_user/create_challenge", type: .post, params: body)
            .flatMap { networkService.load($0, decoding: ChallengeFriendData.self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func acceptChallenge(id: Int, session: String) -> AnyPublisher<ChallengeFriendData, Error> {
        let body = ["session": session]
        return URLRequest
            .create(url: Configuration.host + "/challenge_user/accept_challenge/\(id)", type: .post, params: body)
            .flatMap { networkService.load($0, decoding: ChallengeFriendData.self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func sendScore(id: Int, session: String, score: Int) -> AnyPublisher<ChallengeFriendData, Error> {
        let body = ["session": session, "score": score] as [String : Any]
        return URLRequest
            .create(url: Configuration.host + "/challenge_user/send_score/\(id)", type: .post, params: body)
            .flatMap { networkService.load($0, decoding: ChallengeFriendData.self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }
}
