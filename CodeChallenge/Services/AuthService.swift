//
//  AuthService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import Combine

protocol AuthServiceProtocol {
    func signUp(username: String, email: String, password: String) -> AnyPublisher<User, Error>
    func login(username: String, password: String) -> AnyPublisher<User, Error>
}

struct AuthService: AuthServiceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func signUp(username: String, email: String, password: String) -> AnyPublisher<User, Error> {
        URLRequest
            .create(url: "", type: .post)
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
}
