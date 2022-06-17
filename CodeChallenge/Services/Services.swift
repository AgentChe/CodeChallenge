//
//  Services.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation

protocol ServicesProtocol {
    var networkService: NetworkServiceProtocol { get }
    var authService: AuthServiceProtocol { get }
}

struct Services: ServicesProtocol {
    let networkService: NetworkServiceProtocol
    let authService: AuthServiceProtocol

    init() {
        networkService = NetworkService()
        self.authService = AuthService(networkService: networkService)
    }
}
