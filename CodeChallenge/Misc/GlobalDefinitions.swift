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
    
    static let amplitudeApiKey = "d4ad5c33d23d7a891e9c68de9471f36b"
    
    static let applicationTag = "CODE_LEARNING"
    
    static let termsOfUse = URL(string: "https://cocorporateapps.com/terms-of-use.html")!
    static let privacyPolicy = URL(string: "https://cocorporateapps.com/privacy-policy.html")!
    
    enum Paygate {
        static let weekly = "weekly_subscription_access"
        static let lifetime = "q1_codehub_lifetime"
    }
}
