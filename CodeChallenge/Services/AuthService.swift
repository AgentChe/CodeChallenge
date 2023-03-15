//
//  AuthService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import Combine
import UIKit

protocol AuthServiceProtocol {
    func signUp(id: Int, session: String, username: String, email: String, password: String) -> AnyPublisher<User, Error>
    func login(merge: Bool, session: String, username: String, password: String) -> AnyPublisher<User, Error>
    func guestAuth() -> AnyPublisher<User, Error>
    func logout(session: String) -> AnyPublisher<Void, Error>
    func deleteAccount(session: String, id: Int) -> AnyPublisher<Void, Error>
    func fetchMaintenance() -> AnyPublisher<Maintenance, Error>
}

struct AuthService: AuthServiceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func signUp(id: Int, session: String, username: String, email: String, password: String) -> AnyPublisher<User, Error> {
        let params = ["username": username, "email": email, "password": password, "id": id, "session": session] as [String : Any]
        return URLRequest
            .create(url: "\(Configuration.host)/user/signupWithCreds/", type: .post, params: params)
            .flatMap { networkService.load($0, decoding: User.self, with: JSONDecoder()) }
            .eraseToAnyPublisher()
    }

    func login(merge: Bool, session: String, username: String, password: String) -> AnyPublisher<User, Error> {
        let params: [String: Any] = ["username": username, "password": password, "merge": ["session": session, "merge": merge]]
        
        return URLRequest
            .create(url: "\(Configuration.host)/user/signin/", type: .post, params: params)
            .flatMap { networkService.load($0, decoding: User.self, with: JSONDecoder()) }
            .eraseToAnyPublisher()
    }

    func guestAuth() -> AnyPublisher<User, Error> {
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
            return Fail(error: NetworkError.internalInconsistency).eraseToAnyPublisher()
        }

        let lang = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first
        let params = ["language_name": lang, "device_id": uuid]

        return URLRequest
            .create(url: "\(Configuration.host)/user/signupWithoutCreds/", type: .post, params: params)
            .flatMap { networkService.load($0, decoding: User.self, with: JSONDecoder.snakeCase) }
            .eraseToAnyPublisher()
    }

    func logout(session: String) -> AnyPublisher<Void, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/user/signout/", type: .post, params: ["session": session])
            .flatMap { networkService.send($0) }
            .eraseToAnyPublisher()
    }

    func deleteAccount(session: String, id: Int) -> AnyPublisher<Void, Error> {
        let params = ["session": session, "id": id] as [String : Any]
        return URLRequest
            .create(url: "\(Configuration.host)/user/deleteAccount/", type: .post, params: params)
            .flatMap { networkService.send($0) }
            .eraseToAnyPublisher()
    }

    func fetchMaintenance() -> AnyPublisher<Maintenance, Error> {
        return
            URLRequest.create(url: "https://maintenance.yervandgaloyan.workers.dev/")
            .map {
                var copy = $0
                copy.cachePolicy = .reloadIgnoringCacheData
                return copy
            }
            .flatMap { networkService.load($0, decoding: Maintenance.self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }
}
