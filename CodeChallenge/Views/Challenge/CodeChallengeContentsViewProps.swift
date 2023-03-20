//
//  CodeChallengeContentsViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 20/03/2023.
//

import Foundation

protocol CodeChallengeContentsViewProps {
    var store: Store { get }
    var codeChallenge: Challenge { get }
}

extension CodeChallengeContentsViewProps {
    var details: ChallengeDetail? {
        store.state.challengeDetails[codeChallenge.id]?.value
    }

    var isLoading: Bool {
        return [
            store.state.challengeProgresses[codeChallenge.id]?.isLoading,
            store.state.challengeResults[codeChallenge.id]?.isLoading
        ].contains { $0 == true }
    }

    var programmingLanguage: ProgrammingLanguage {
        details?.codehubProgrammingLanguage ?? .python
    }

    var code: String {
        if let progress = store.state.challengeProgresses[details?.id ?? 0]?.value {
            return progress.solution?.python ?? template
        } else {
            return template
        }
    }

    var template: String {
        return details?.body.template ?? ""
    }

    var account: Account? {
        store.state.account.value
    }

    var shouldShowPremiumPopup: Bool {
        details?.isPremium == true && account?.isPremium == false
    }
}
