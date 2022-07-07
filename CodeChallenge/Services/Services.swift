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
    var accountService: AccountServiceProtocol { get }
}

struct Services: ServicesProtocol {
    let networkService: NetworkServiceProtocol
    let authService: AuthServiceProtocol
    let accountService: AccountServiceProtocol

    init() {
        networkService = NetworkService()
        self.authService = AuthService(networkService: networkService)
        self.accountService = AccountService(networkService: networkService)
    }
}
