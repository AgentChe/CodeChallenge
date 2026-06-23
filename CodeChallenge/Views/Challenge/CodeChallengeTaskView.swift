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
    let onOpenChat: ((ChatMessagesMode) -> Void)?

    @State private var bodyAttributedString: NSMutableAttributedString?

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Spacer()
                        .frame(height: 25)
                    Text(details.name)
                        .font(.h3)
                    if let bodyAttributedString = bodyAttributedString {
                        HtmlAttributedLabel(htmlAttributedString: bodyAttributedString, foregroundColor: .white)
                            .frame(width: .screenWidth - 40)
                    }

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
                                    onOpenChat(.provideSolution(details))
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
                                onOpenChat(.provideSolution(details))
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
        // Parse the HTML description OUTSIDE the SwiftUI view-update transaction.
        // `NSAttributedString` HTML parsing spins up a nested WebKit run loop;
        // calling it inside `body` (as `details.body.toAttributedString()` did)
        // re-entered SwiftUI's graph update, producing "Publishing changes from
        // within view updates", AttributeGraph cycles and an over-release crash
        // in HVStack.updateCache. `.task` runs on the main actor but after the
        // update, so the nested run loop is safe here.
        .task(id: details) {
            bodyAttributedString = details.body.toAttributedString()
        }
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
