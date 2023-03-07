//
//  LeaderboardViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/03/2023.
//

import Foundation

protocol LeaderboardViewProps {
    var store: Store { get } 
}

extension LeaderboardViewProps {
    var account: Account? {
        store.state.account.value
    }
    
    var leaderboard: LeaderboardData? {
        store.state.leaderboardData.value
    }

    var topUsers: [LeaderboardUser] {
        leaderboard?.topUsers ?? []
    }

    var neightborUsers: [LeaderboardUser] {
        leaderboard?.userNeighbors ?? []
    }

    var isLoading: Bool {
        store.state.leaderboardData.isLoading
    }
}
