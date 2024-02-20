//
//  Account.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation

class Account {
    var id: Int?
    var name: String?
    var username: String?
    var solvedChallenges: Int?
    var followersCount: Int?
    var followingsCount: Int?
    var streak: Int?
    var xp: Int?
    
    var isPremium: Bool? {
        SessionManager().hasActiveSubscriptions()
    }

    init() {}
}

extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.id == rhs.id && lhs.xp == rhs.xp && rhs.solvedChallenges == lhs.solvedChallenges
    }
}

extension Account {
    var imageUrl: String {
        "\(Configuration.host)/user/getImage/\(id ?? 0)/"
    }
}

extension Account {
    struct StreakWeekdayInfo: Hashable {
        let key: String
        let value: Bool
    }
    func streaktoKeyValueTuple(from number: Int) -> [StreakWeekdayInfo] {
        let weekdays = [("Sun", "S"), ("Mon", "M"), ("Tue", "T"), ("Wed", "W"), ("Thu", "T"), ("Fri", "F"), ("Sat", "S")]
        let weekday = Calendar.current.component(.weekday, from: Date()) - 1
        let weekdayDisplay = weekdays.reduce([StreakWeekdayInfo]()) { partialResult, result in
            let correspondingWeekday = (weekdays.firstIndex { $0.0 == result.0 }) ?? 0
            let valueSelected = correspondingWeekday <= weekday && (number > 6 || correspondingWeekday + number > weekday )
            return partialResult + [StreakWeekdayInfo(key: result.1,
                                                      value: valueSelected)]
        }
        return weekdayDisplay
    }
}

