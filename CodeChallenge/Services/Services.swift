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
    var analyticsService: AnalyticsServiceProtocol { get }
    var identifyService: IdentifyServiceProtocol { get }
    var purchasesService: PurchasesServiceProtocol { get }
    var rewardsService: RewardsServiceProtocol { get }
    var conceptReviewService: ConceptReviewServiceProtocol { get }
}

struct Services: ServicesProtocol {
    let networkService: NetworkServiceProtocol
    let authService: AuthServiceProtocol
    let accountService: AccountServiceProtocol
    let challengesService: ChallengesServiceProtocol
    let imageService: ImageServiceProtocol
    let analyticsService: AnalyticsServiceProtocol
    let identifyService: IdentifyServiceProtocol
    let purchasesService: PurchasesServiceProtocol
    let rewardsService: RewardsServiceProtocol
    let conceptReviewService: ConceptReviewServiceProtocol

    init() {
        networkService = NetworkService()
        self.authService = AuthService(networkService: networkService)
        self.accountService = AccountService(networkService: networkService)
        self.challengesService = ChallengesService(networkService: networkService)
        self.imageService = ImageService()
        self.analyticsService = AnalyticsService()
        self.identifyService = IdentifyService()
        self.purchasesService = PurchasesService(networkService: networkService)
        self.rewardsService = RewardsService(networkService: networkService)
        self.conceptReviewService = ConceptReviewService(networkService: networkService)
    }
}
