//
//  QuickAccessCharsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 09/08/2022.
//

import SwiftUI

struct QuickAccessCharsView: View {
    @EnvironmentObject var store: Store
    let challengeId: Int
    let chars = ["TAB", "(", ")", "\"", "\'", "{", "}", "[", "]", ",", "=", "!", "/", ".", ";", "<", ">",
                 "&", "|", "#", "*", "+", "-", ":", "%", "_", "@", "?", "^"]
    let onRun: () -> Void
    let onSelectingChar: (String) -> Void
    let height: CGFloat = UIDevice.hasSmallScreen ? 65 : 95

    var isLoading: Bool {
        store.state.challengeResults[challengeId]?.isLoading == true
    }

    var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(chars, id: \.self) { char in
                        charView(char: char)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                if char == "TAB" {
                                    onSelectingChar("  ")
                                } else {
                                    onSelectingChar(char)
                                }
                            }
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width - 89, height: 33)
            ZStack {
                if isLoading {
                    ZStack {
                        Image("run_button_background")
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    }
                } else {
                    Image("run_button")
                        .onTapGesture {
                            onRun()
                        }
                }
            }
            .frame(width: 70)
        }
        .padding(.vertical, UIDevice.hasSmallScreen ? 10 : 25)
        .padding(.horizontal, 18)
        .background(.CodeChallenge.tabBar)
        .frame(width: UIScreen.main.bounds.width, height: height)
    }

    private func charView(char: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(UIColor.CodeChallenge.lightBlue))
                .frame(height: 33)
            Text(char)
                .font(.systemFont(ofSize: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
        }
        .frame(height: 33)
    }
}
