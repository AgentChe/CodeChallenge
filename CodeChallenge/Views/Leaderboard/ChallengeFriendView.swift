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
//            Text("Challenge Friends!")
//                .font(.pageNameH1)
//                .foregroundColor(.white)
            HStack {
                Image("challenge_friend")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: .screenWidth - 100)
                Spacer()
            }
            Text("Let's start by selecting the language and difficulty level you want to challenge friends with. Complete the challenges yourself and earn rewards upon winning!")
                .multilineTextAlignment(.leading)
                .foregroundColor(.white)
                .font(.bodyText)

            HStack {
                Text("Language")
                    .font(.h5)
                Spacer()
                Picker("Select language", selection: $programmingLanguage) {
                    ForEach(ProgrammingLanguage.allCases, id: \.rawValue) { language in
                        Text(language.rawValue.capitalized)
                            .onTapGesture {
                                programmingLanguage = language.rawValue.capitalized
                            }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(UIColor.CodeChallenge.blue1))
            }
            HStack {
                Text("Difficulty level")
                    .font(.h5)
                Spacer()
                Picker("Select difficulty level", selection: $difficultyLevel) {
                    ForEach(["Easy", "Medium", "Hard"], id: \.self) { level in
                        Text(level)
                            .onTapGesture {
                                difficultyLevel = level
                            }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(UIColor.CodeChallenge.blue1))
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
