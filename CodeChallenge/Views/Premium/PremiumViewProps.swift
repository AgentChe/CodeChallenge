//
//  PremiumViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 04/08/2022.
//

import Foundation

protocol PremiumViewProps {
    var store: Store { get }
}

extension PremiumViewProps {
    var infoDates: (String, String) {
        let date = Date()
        let calendar = Calendar.current
        let dates = (calendar.date(byAdding: .day, value: 12, to: date)!,
                     calendar.date(byAdding: .day, value: 14, to: date)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return (formatter.string(from: dates.0), formatter.string(from: dates.1))
    }
    var getPremiumTexts: [(String, String)] {
        return [("Today", "Get instant access and see how it\ncan improve your Python skills."), (infoDates.0, "We’ll remind you with an email or push\nnotification that your trial is ending."), (infoDates.1, "You’ll be charged on \(infoDates.1);\ncancel anytime before.")]
    }

    var payments: [AppStorePayment] {
        return store.state.payments.value ?? []
    }

    var yearlyPayment: AppStorePayment? {
        return payments.first { $0.productIdentifier == "yearly_pro_2week_trial" }
    }

    var buttonStatus: GradientButton.Status {
        if store.state.account.isLoading || store.state.account.isPending {
            return .loading
        } else {
            return .enabled
        }
    }
}
