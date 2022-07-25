//
//  EnvironmentAdditions.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/08/2022.
//

import Foundation
import SwiftUI

struct InstanceIDKey: EnvironmentKey {
    static var defaultValue: UUID = .init()
}

extension EnvironmentValues {
    var instanceID: UUID {
        get { self[InstanceIDKey.self] }
        set { self[InstanceIDKey.self] = newValue }
    }
}
