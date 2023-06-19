//
//  OnboardingSummaryPage.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 12/06/2023.
//

import Foundation
import SwiftUI

struct OnboardingSummaryView: View {
    let result: [(OnboardingStep, String)]
    let amount: String
    let onGetPlan: () -> Void
    
    var body: some View {
        DoodledView {
            VStack {
                ScrollView {
                    VStack(spacing: 30) {
                        Text("Your learning plan is ready")
                            .font(.pageNameH1)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)

                        Image("onboarding_summary_graph_\(amount)")
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Designed for you")
                                    .foregroundColor(UIColor.CodeChallenge.purple2)
                                    .font(.regular(size: 12))
                                ForEach((result.filter { $0.0.summaryTitle != nil }), id: \.0.title)  { item in
                                    VStack(alignment: .leading) {
                                        Text(item.0.summaryTitle ?? "")
                                            .foregroundColor(.CodeChallenge.lightBlue)
                                            .font(.regular(size: 14))
                                        Text(item.1)
                                            .foregroundColor(.CodeChallenge.white)
                                            .font(.h4)
                                    }
                                }
                                VStack(alignment: .leading) {
                                    Text("Practice lessons")
                                        .foregroundColor(.CodeChallenge.lightBlue)
                                        .font(.regular(size: 14))
                                    Text("500 lessons")
                                        .foregroundColor(.CodeChallenge.white)
                                        .font(.h4)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor.CodeChallenge.gray))
                        }
                        
                        Text("Please note that the selected salary indicated during the onboarding process is solely an estimation, and we do not provide any guarantee that you will receive that specific amount.")
                            .multilineTextAlignment(.center)
                            .font(.bodyText)
                            .foregroundColor(.lightGray)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                    }
                    .padding(.horizontal, 16)
                }
                Button("Get my plan", action: onGetPlan).buttonStyle(PrimaryButton())
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 20)
        }
    }
}
