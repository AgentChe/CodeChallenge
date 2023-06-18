//
//  OnboardingStepView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 12/06/2023.
//

import Foundation
import SwiftUI

struct OnboardingStep {
    let title: String
    let summaryTitle: String?
    let options: [(image: String?, title: String, secondaryTitle: String?)]
}

struct OnboardingStepView: View {
    let onNext: (String) -> Void
    let step: OnboardingStep
    @State private var selectedOption: String = ""
    
    var body: some View {
        DoodledView {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        Text(step.title)
                            .font(.h2)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 24)
                        ForEach(step.options, id: \.title) { option in
                            HStack(spacing: 16) {
                                if let image = option.image {
                                    Image(image)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                }
                                Text(option.title)
                                    .font(.h4)
                                Spacer()
                                if let title = option.secondaryTitle {
                                    Text(title)
                                        .foregroundColor(.CodeChallenge.lightPurple)
                                        .font(.h5)
                                }
                            }
                            .padding(.vertical, option.image != nil ? 8 : 21)
                            .padding(.horizontal, 20)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(option.title == selectedOption ? UIColor.CodeChallenge.blue1 : UIColor.lightGray), lineWidth: 1.5)
                            }
                            .onTapGesture {
                                selectedOption = option.title
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                Button("Continue", action: {
                    guard !selectedOption.isEmpty else { return }
                    onNext(selectedOption)
                }).buttonStyle(PrimaryButton(status: !selectedOption.isEmpty ? PrimaryButton.Status.enabled : PrimaryButton.Status.disabled))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
        }
    }
}

