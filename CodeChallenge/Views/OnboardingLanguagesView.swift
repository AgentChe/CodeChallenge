//
//  OnboardingLanguages.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 24/12/2022.
//

import Foundation
import SwiftUI

struct OnboardingLanguagesView: View {
    @EnvironmentObject var store: Store
    let allLanguages = ProgrammingLanguage.allCases
    let onDismiss: () -> Void
    @State private var selectedLanguage: ProgrammingLanguage = .python

    var body: some View {
        DoodledView {
            VStack(alignment: .center, spacing: 8) {
                Spacer()
                    .frame(height: 24)
                Text("What do you want to learn?")
                    .font(.h2)
                Text("You can always switch paths later on")
                    .font(.h5)
                Spacer()
                    .frame(height: 48)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(allLanguages, id: \.rawValue) { language in
                            languageView(language)
                                .clipShape(Rectangle())
                                .onTapGesture {
                                    selectedLanguage = language
                                }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                Spacer()
                Button("Continue") {
                    onDismiss()
                    store.dispatch(GetLearnSections(programmingLanguage: selectedLanguage))
                    store.dispatch(ChangeProgrammingLanguage(language: selectedLanguage))
                }
                .buttonStyle(PrimaryButton())
                .padding(.horizontal, 16)
            }
            .foregroundColor(.white)
        }
    }

    private func languageView(_ language: ProgrammingLanguage) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13)
                .stroke(language != selectedLanguage ?
                        Color(.CodeChallenge.dustyBlue) : Color(.CodeChallenge.blue1),
                        lineWidth: 1.5)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Spacer()
                    Image(language.rawValue)
                        .resizable()
                        .frame(width: .screenHeight * 0.18, height: .screenHeight * 0.18)
                        .padding([.top, .horizontal], 10)
                    Spacer()
                }
                Text(language.rawValue.capitalized)
                    .font(.h3)
                    .padding(.top, 9)
                    .padding(.horizontal, 16)
                Text(language.description)
                    .font(.bodyText)
                    .padding(.horizontal, 16)
                Spacer()
            }
            .foregroundColor(.white)
        }
        .frame(width: .screenWidth - 100, height: .screenHeight * 0.4)
    }
}
