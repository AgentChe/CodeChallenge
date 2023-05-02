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

    var code: String? {
        if let progress = store.state.challengeProgresses[details?.id ?? 0]?.value {
            return progress.solution?.python.removingPercentEncoding ?? details?.body.template.removingPercentEncoding
        } else {
            return details?.body.template.removingPercentEncoding
        }
    }

    var body: some View {
        VStack {
            if let details = details {
                detailsContent(details)
            } else {

            }
        }
        .onAppear {
            displayCode = code
            onCodeChange(displayCode ?? "")
        }
        .onChange(of: code, perform: { newValue in
            displayCode = newValue
            onCodeChange(newValue ?? "")
        })
    }

    func detailsContent(_ details: ChallengeDetail) -> some View {
        VStack {
            HtmlAttributedLabel(htmlAttributedString: details.body.toAttributedString(), foregroundColor: .white)
                .frame(width: .screenWidth - 40)

            SimpleCodePlaygroundView(code: $displayCode, onCodeUpdate: { newValue in
                onCodeChange(newValue ?? "")
            })
                .frame(height: 200)
                .padding(.horizontal, 20)
            Spacer()
        }
    }
}
