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
    var challengesService: ChallengesServiceProtocol { get }
    var imageService: ImageServiceProtocol { get }
}

struct Services: ServicesProtocol {
    let networkService: NetworkServiceProtocol
    let authService: AuthServiceProtocol
    let accountService: AccountServiceProtocol
    let challengesService: ChallengesServiceProtocol
    let imageService: ImageServiceProtocol

    init() {
        networkService = NetworkService()
        self.authService = AuthService(networkService: networkService)
        self.accountService = AccountService(networkService: networkService)
        self.challengesService = ChallengesService(networkService: networkService)
        self.imageService = ImageService()
    }
}
