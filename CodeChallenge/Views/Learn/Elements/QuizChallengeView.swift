//
//  QuizChallengeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 14/04/2023.
//

import Foundation
import SwiftUI

struct QuizChallengeView: View {
    @EnvironmentObject var store: Store
    let id: Int
    let onCodeChange: (String) -> Void
    @State private var displayCode: String? = nil
    @State private var showsResetProgressPopup = false

    var details: ChallengeDetail? {
        store.state.challengeDetails[id]?.value
    }

    var isLoading: Bool {
        store.state.challengeProgresses[details?.id ?? 0]?.isLoading == true
    }

    var code: String? {
        if let progress = store.state.challengeProgresses[details?.id ?? 0]?.value {
            return progress.solution?.python.removingPercentEncoding ?? progress.solution?.python ?? details?.body.template.removingPercentEncoding
        } else {
            return details?.body.template.removingPercentEncoding
        }
    }

    var body: some View {
        VStack {
            if let details = details {
                detailsView(details)
            }
        }
        .onAppear {
            if !isLoading {
                displayCode = code
                onCodeChange(code ?? "")
            }
        }
        .onChange(of: code, perform: { newValue in
            if !isLoading {
                displayCode = newValue
                onCodeChange(newValue ?? "")
            }
        })
    }

    private func detailsView(_ details: ChallengeDetail) -> some View {
        VStack {
            HtmlAttributedLabel(htmlAttributedString: details.body.toAttributedString(), foregroundColor: .white)
                .frame(width: .screenWidth - 40)

            Spacer()
                .frame(height: 20)

            SimpleCodePlaygroundView(code: $displayCode, onCodeUpdate: { newValue in
                onCodeChange(newValue)
            })
                .frame(height: 200)
                .disabled(isLoading)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    Rectangle()
                        .fill(Color(UIColor.CodeChallenge.darkBlue))
                }
            Spacer()
        }
    }
}
