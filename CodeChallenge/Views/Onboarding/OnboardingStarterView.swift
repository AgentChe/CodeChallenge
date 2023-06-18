//
//  OnboardingStarterPage.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 12/06/2023.
//

import Foundation
import SwiftUI

struct OnboardingStarterPage: View {
    let onStart: () -> Void
    let onLogin: () -> Void
    var body: some View {
        DoodledView {
            VStack(spacing: 0) {
                Image("onboarding_stater_image")
                Spacer()
                Text("Learn coding in 10 minutes a day")
                    .multilineTextAlignment(.center)
                    .font(.semibold(size: 30))
                Spacer()
                    .frame(height: 30)
                Button("Start Learning", action: {
                    onStart()
                }).buttonStyle(PrimaryButton())
                                
                Button(action: onLogin) {
                    Text("Have an account? ").foregroundColor(Color.white) +
                    Text("Log in")
                }
                .font(.regular(size: 16))
                .padding(.top, 40)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
}
