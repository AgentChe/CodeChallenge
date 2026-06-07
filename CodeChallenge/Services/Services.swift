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
    var rewardsService: RewardsServiceProtocol { get }
    var conceptReviewService: ConceptReviewServiceProtocol { get }
    var leaderboardService: LeaderboardServiceProtocol { get }
    var chatService: ChatServiceProtocol { get }
    var challengeFriendService: ChallengeFriendServiceProtocol { get }
}

struct Services: ServicesProtocol {
    let networkService: NetworkServiceProtocol
    let authService: AuthServiceProtocol
    let accountService: AccountServiceProtocol
    let challengesService: ChallengesServiceProtocol
    let imageService: ImageServiceProtocol
    let rewardsService: RewardsServiceProtocol
    let conceptReviewService: ConceptReviewServiceProtocol
    let leaderboardService: LeaderboardServiceProtocol
    let chatService: ChatServiceProtocol
    let challengeFriendService: ChallengeFriendServiceProtocol

    init() {
        networkService = NetworkService()
        self.authService = AuthService(networkService: networkService)
        self.accountService = AccountService(networkService: networkService)
        self.challengesService = ChallengesService(networkService: networkService)
        self.imageService = ImageService()
        self.rewardsService = RewardsService(networkService: networkService)
        self.conceptReviewService = ConceptReviewService(networkService: networkService)
        self.leaderboardService = LeaderboardService(networkService: networkService)
        self.chatService = ChatService(networkService: networkService)
        self.challengeFriendService = ChallengeFriendService(networkService: networkService)
    }
}
