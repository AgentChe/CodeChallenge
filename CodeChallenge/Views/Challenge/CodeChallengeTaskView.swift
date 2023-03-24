//
//  CodeChallengeTaskView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 20/03/2023.
//

import Foundation
import SwiftUI

struct CodeChallengeTaskView: View {
    @EnvironmentObject var store: Store
    let details: ChallengeDetail
    let onStartSolving: () -> Void
    let onPremiumPopupShow: (() -> Void)?
    let onGoPremium: (() -> Void)?
    let onOpenChat: ((ChallengeDetail?, ChatMessagesMode) -> Void)?

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Spacer()
                        .frame(height: 25)
                    Text(details.name)
                        .font(.h3)
                    HtmlAttributedLabel(htmlAttributedString: details.body.toAttributedString(), foregroundColor: .white)
                        .frame(width: .screenWidth - 40)

                    if let input = taskInput {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Input:")
                                .foregroundColor(.CodeChallenge.mediumBlue)
                                .font(.medium(size: 20))
                            Text(input)
                                .foregroundColor(.white)
                                .font(.h5)
                        }
                    }

                    if let output = taskOutput {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Output:")
                                .foregroundColor(.CodeChallenge.mediumBlue)
                                .font(.medium(size: 20))
                            Text(output)
                                .foregroundColor(.white)
                                .font(.h5)
                        }
                    }
                }
                .frame(width: .screenWidth - 40)
                .padding(.horizontal, 20)
            }
            Spacer()
            if details.isPremium {
                HStack(spacing: 10) {
                    Button("Start solving", action: {
                        if shouldShowPremiumPopup, let onPremiumPopupShow = onPremiumPopupShow {
                            onPremiumPopupShow()
                        } else {
                            onStartSolving()
                        }
                    })
                    .buttonStyle(PremiumGradientButton())
                    if store.state.maintenance?.aiEnabled == true, let onPremiumPopupShow = onPremiumPopupShow,
                        let onOpenChat = onOpenChat {
                        aiButton
                            .modifier(PremiumGradientModifier())
                            .onTapGesture {
                                if shouldShowPremiumPopup {
                                    onPremiumPopupShow()
                                } else {
                                    onOpenChat(details, .provideSolution)
                                }
                            }
                    }
                }
                .padding(20)
            } else {
                HStack(spacing: 10) {
                    Button("Start solving") {
                        onStartSolving()
                    }
                    .buttonStyle(PrimaryButton())
                    if store.state.maintenance?.aiEnabled == true, let onOpenChat = onOpenChat {
                        aiButton
                            .onTapGesture {
                                onOpenChat(details, .provideSolution)
                            }
                            .background {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(UIColor.CodeChallenge.blue1))
                            }
                    }
                }
                .padding(20)
            }

        }
        .foregroundColor(.CodeChallenge.white)
    }

    private var aiButton: some View {
        HStack {
            Spacer()
            Image("ai")
                .resizable()
                .frame(width: 36, height: 36)
            Text("Ask AI")
                .font(.button)
                .foregroundColor(.white)
                .frame(height: 56)
            Spacer()
        }
        .frame(width: .screenWidth/2 - 23)
    }
}

extension CodeChallengeTaskView {
    var taskInput: String? {
        details.body.input
    }

    var taskOutput: String? {
        details.body.output
    }

    var shouldShowPremiumPopup: Bool {
        details.isPremium == true && account?.isPremium == false
    }

    var account: Account? {
        store.state.account.value
    }
}
