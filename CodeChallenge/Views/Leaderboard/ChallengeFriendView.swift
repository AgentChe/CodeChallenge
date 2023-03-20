//
//  ChallengeFriendView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 18/03/2023.
//

import Foundation
import SwiftUI

struct ChallengeFriendView: View, ChallengeFriendViewProps {
    @EnvironmentObject var store: Store
    @State private var difficultyLevel = "Easy"
    @State private var programmingLanguage = "Python"
    let onShareAndStart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Challenge Friends!")
                .font(.pageNameH1)
                .foregroundColor(.white)
            Text("Select the language and difficulty level you want to challenge friends with. Complete the challenges yourself and earn rewards upon winning!")
                .foregroundColor(.white)
                .font(.h3)

            HStack {
                Text("Select language")
                    .font(.h4)
                Picker("Select language", selection: $programmingLanguage) {
                    ForEach(ProgrammingLanguage.allCases, id: \.rawValue) { language in
                        Text(language.rawValue.capitalized)
                            .onTapGesture {
                                programmingLanguage = language.rawValue.capitalized
                            }
                    }
                }
            }
            HStack {
                Text("Select difficulty level")
                    .font(.h4)
                Picker("Select difficulty level", selection: $difficultyLevel) {
                    ForEach(["Easy", "Medium", "Hard"], id: \.self) { level in
                        Text(level)
                            .onTapGesture {
                                difficultyLevel = level
                            }
                    }
                }
            }
            Spacer()

            Button("Send the link & Start") {
                store.dispatch(CreateChallengeWithFriend(
                    programmingLanguage: .init(rawValue: programmingLanguage.lowercased()) ?? .python,
                    difficulty: difficultyLevel)
                )
                onShareAndStart()
            }
            .buttonStyle(PrimaryButton())
        }
        .padding(20)
    }
}
