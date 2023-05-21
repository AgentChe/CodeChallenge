//
//  LearnTabView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 16/04/2023.
//

import Foundation
import SwiftUI

struct LearnTabView: View, LearnTabViewProps {
    @EnvironmentObject var store: Store
    let onElementTap: (LearnElement) -> Void
    let onJumpSection: (LearnSection) -> Void
    let onOpenPremium: () -> Void
    let onJumpSignUp: () -> Void
    @State private var showProgrammingLanguagePopup = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(showsIndicators: false) {
                    LearnTabSectionsView(
                        onElementTap: onElementTap,
                        onOpenPremium: onOpenPremium,
                        onJumpSection: onJumpSection,
                        onJumpSignUp: onJumpSignUp
                    )
                }
                .padding(.top, 10)
            }

            if showProgrammingLanguagePopup {
                Rectangle()
                    .fill(Color.black)
                    .opacity(0.85)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showProgrammingLanguagePopup = false
                        }
                    }
                changeLanguagePopup
                    .transition(.move(edge: .bottom).animation(.easeInOut(duration: 0.3)))
                    .zIndex(3)
            }
        }
        .background(.CodeChallenge.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 10) {
                    if store.state.maintenance?.premium == true, !isPremium {
                        HStack(spacing: 4) {
                            Text("Go Premium")
                                .foregroundColor(.CodeChallenge.white)
                                .font(.h5)
                            Image("challenge_premium_icon")
                                .resizable()
                                .frame(width: 14, height: 12)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.CodeChallenge.blue1))
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.CodeChallenge.dark)))
                        )
                        .onTapGesture {
                            onOpenPremium()
                        }
                    }
                    LanguagePickerIconView()
                        .onTapGesture {
                            withAnimation {
                                showProgrammingLanguagePopup = true
                            }
                        }
                    DefaultXPView(
                        xpText: "\(xp)",
                        backgroundColor: .CodeChallenge.dark,
                        xpIconColor: "white",
                        strokeColor: .CodeChallenge.blue1
                    )
                }
            }
        }
        .onChange(of: programmingLanguage) { newValue in
            store.dispatch(LoadPracticeSections(language: newValue))
            store.dispatch(GetLearnSections(programmingLanguage: newValue))
        }
    }

    private var changeLanguagePopup: some View {
        VStack {
            Spacer()
            ZStack(alignment: .leading) {
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 10)
                    Text("Choose Language")
                        .font(.h2)
                        .padding(.horizontal, 4)
                    ForEach(ProgrammingLanguage.allCases, id: \.rawValue) { language in
                        languageView(language: language)
                            .padding(.horizontal, 20)
                            .onTapGesture {
                                store.dispatch(ChangeProgrammingLanguage(language: language))
                                store.dispatch(LoadRecommendedChallenges())
                                withAnimation {
                                    showProgrammingLanguagePopup = false
                                }
                            }
                            .contentShape(Rectangle())
                    }
                    Button("Cancel") {
                        withAnimation {
                            showProgrammingLanguagePopup.toggle()
                        }
                    }
                    .foregroundColor(.white.withAlphaComponent(0.6))
                    .font(.smallText)
                    .padding(.bottom, 20)
                }
                .foregroundColor(.white)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.CodeChallenge.background))
                }
            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .frame(width: .screenWidth)
    }

    private func languageView(language: ProgrammingLanguage) -> some View {
        HStack(spacing: 12) {
            Image(language.rawValue)
                .resizable()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 7) {
                Text(language.rawValue.capitalized)
                    .font(.h5)
                Text(language.shortDescription)
                    .font(.smallText)
                    .foregroundColor(.white.withAlphaComponent(0.6))
            }
            Spacer()
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(UIColor.CodeChallenge.purple), lineWidth: 1.2)
        }
    }
}
