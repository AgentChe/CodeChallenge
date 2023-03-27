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
                    .frame(width: .screenWidth)
                Spacer()
            }

            description
                .multilineTextAlignment(.leading)
                .foregroundColor(.white)
                .padding(.leading, 20)
                .padding(.trailing, 60)
                .padding(.top, -60)
                .lineSpacing(1.2)

            HStack(spacing: 20) {
                Picker("Select language", selection: $programmingLanguage) {
                    ForEach(ProgrammingLanguage.allCases, id: \.rawValue) { language in
                        Text(language.rawValue.capitalized)
                            .onTapGesture {
                                programmingLanguage = language.rawValue.lowercased()
                            }
                    }
                }
                .tint(.white)
                .background {
                    Capsule()
                        .stroke(Color(UIColor.CodeChallenge.blue1))
                }

                Picker("Select difficulty level", selection: $difficultyLevel) {
                    ForEach(["Easy", "Medium", "Hard"], id: \.self) { level in
                        Text(level)
                            .onTapGesture {
                                difficultyLevel = level
                            }
                    }
                }
                .tint(.white)
                .background {
                    Capsule()
                        .stroke(Color(UIColor.CodeChallenge.blue1))
                }

            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Button("Share & Start") {
                store.dispatch(CreateChallengeWithFriend(
                    programmingLanguage: .init(rawValue: programmingLanguage.lowercased()) ?? .python,
                    difficulty: difficultyLevel)
                )
                onShareAndStart()
            }
            .buttonStyle(PrimaryButton())
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()
        }
        .padding(.vertical, 20)
    }

    private var description: some View {
        Text("Let's start by selecting ")
            .font(.bodyText)
        +
        Text("the language ")
            .font(.bold(size: 14))
        +
        Text("and ")
            .font(.bodyText)
        +
        Text("difficulty level ")
            .font(.bold(size: 14))
        +
        Text("you want to challenge friends with. Complete the challenges yourself and ")
            .font(.bodyText)
        +
        Text("earn xps upon winning!")
            .font(.bold(size: 14))
    }
}
