//
//  GlobalDefinitions.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 20.02.2024.
//

import Foundation

enum GlobalDefinitions {
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "aYIILMSLfJK1Q8RT"
    
    static let termsOfUse = URL(string: "https://cocorporateapps.com/terms-of-use.html")!
    static let privacyPolicy = URL(string: "https://cocorporateapps.com/privacy-policy.html")!
    
    enum Paygate {
        static let weekly = "weekly_subscription_access"
    }
}
