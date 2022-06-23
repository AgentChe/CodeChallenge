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
    func login(username: String, password: String) -> AnyPublisher<User, Error>
    func guestAuth() -> AnyPublisher<User, Error>
    func logout(session: String) -> AnyPublisher<Void, Error>
}

struct AuthService: AuthServiceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func signUp(id: Int, session: String, username: String, email: String, password: String) -> AnyPublisher<User, Error> {
        let params = ["username": username, "email": email, "password": password, "id": id, "session": session] as [String : Any]
        return URLRequest
            .create(url: "http://45.153.215.175:9000/user/signupWithCreds/", type: .post, params: params)
            .flatMap { networkService.load($0, decoding: User.self, with: JSONDecoder()) }
            .eraseToAnyPublisher()
    }

    func login(username: String, password: String) -> AnyPublisher<User, Error> {
        let params = ["username": username, "password": password]
        
        return URLRequest
            .create(url: "http://45.153.215.175:9000/user/signin", type: .post, params: params)
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
            .create(url: "http://45.153.215.175:9000/user/signupWithoutCreds/", type: .post, params: params)
            .flatMap { networkService.load($0, decoding: User.self, with: JSONDecoder()) }
            .eraseToAnyPublisher()
    }

    func logout(session: String) -> AnyPublisher<Void, Error> {
        return URLRequest
            .create(url: "http://45.153.215.175:9000/user/signout/", type: .post, params: ["session": session])
            .flatMap { networkService.send($0) }
            .eraseToAnyPublisher()
    }
}
