//
//  Account.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation

struct Account: Decodable {
    let name: String
    let username: String
    let solvedChallenges: Int
    let followersCount: Int
    let followingsCount: Int
    let streak: Int
    let streakWeekdays: [String]
}

extension Account {
    struct StreakWeekdayInfo: Hashable {
        let key: String
        let value: Bool
    }
    func streaktoKeyValueTuple() -> [StreakWeekdayInfo] {
        let weekdays = [("Mon", "M"), ("Tue", "T"), ("Wed", "W"), ("Thu", "T"), ("Fri", "F"), ("Sat", "S"), ("Sun", "S")]
        let weekdayDisplay = weekdays.reduce([StreakWeekdayInfo]()) { partialResult, result in
            return partialResult + [StreakWeekdayInfo(key: result.1, value: streakWeekdays.contains(result.0))]
        }
        return weekdayDisplay
    }
}
