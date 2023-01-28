//
//  Formatters.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 10/12/2022.
//

import Foundation

extension NumberFormatter {
    static func price(from double: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .down
        formatter.decimalSeparator = "."
        formatter.locale = Locale(identifier: "en_us")
        return formatter.string(from: NSNumber(value: double)) ?? ""
    }
}
