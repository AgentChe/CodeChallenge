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
    
    static let termsOfUse = URL(string: "https://thinkaboutapps.com/terms")!
    static let privacyPolicy = URL(string: "https://thinkaboutapps.com/policy")!
    
    enum Paygate {
        static let yearly = "yearly_pro_3day_trial"
        static let weekly = "weekly_with_trial"
    }
}
