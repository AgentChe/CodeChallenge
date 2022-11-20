//
//  CompletedChallengesView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 20/11/2022.
//

import Foundation
import SwiftUI

struct CompletedChallengesView: View, CompletedChallengesViewProps {
    @EnvironmentObject var store: Store
    let onEnterDetails: ((Challenge) -> Void)
    @State var displayCompletedChallenges: [Challenge] = []

    var body: some View {
        DoodledView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Completed Challenges")
                        .font(.systemFont(ofSize: 30, weight: .semibold))
                        .foregroundColor(.CodeChallenge.white)
                        .multilineTextAlignment(.leading)
                    ForEach(challenges, id: \.id) { challenge in
                        UniversalCodeChallengeView(codeChallenge: challenge)
                            .onTapGesture {
                                onEnterDetails(challenge)
                            }
                    }
                    Spacer()
                        .frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .onChange(of: challenges) { newValue in
            displayCompletedChallenges = newValue
        }
    }
}
