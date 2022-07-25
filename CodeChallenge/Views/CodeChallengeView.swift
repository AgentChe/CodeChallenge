//
//  CodeChallengeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation
import SwiftUI

struct CodeChallengeView: View, CodeChallengeViewProps {
    @EnvironmentObject var store: Store
    let codeChallenge: Challenge
    @State var selection: Int = 0

    var body: some View {
        DoodledView {
            Picker("", selection: $selection) {
                Text("Problem").tag(0)
                Text("Code").tag(1)
                Text("Result").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 25)

            Group {
                switch selection {
                case 0:
                    problemScreen
                case 1:
                    codeScreen
                case 2:
                    resultScreen
                default: Text("")
                }
            }
        }
        .navigationTitle(codeChallenge.name)
    }

    var problemScreen: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Spacer()
                        .frame(height: 25)
                    Text(codeChallenge.name)
                        .font(.systemFont(ofSize: 18, weight: .semibold))
                    Text(codeChallenge.tagsDescription)
                        .font(.systemFont(ofSize: 14))
                        .foregroundColor(.CodeChallenge.blue1)
                    Text(codeChallenge.body)
                        .font(.systemFont(ofSize: 14))
                }
            }
            Spacer()
            Button("Start solving") {
                selection = 1
            }
            .buttonStyle(PrimaryButton())
            .padding(.bottom, 20)
        }
        .foregroundColor(.CodeChallenge.white)
        .padding(.horizontal, 20)
    }

    var codeScreen: some View {
        CodePlaygroundView()
    }

    var resultScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                    .frame(height: 25)
                Text(codeChallenge.name)
                    .font(.systemFont(ofSize: 18, weight: .semibold))
                Text(codeChallenge.body)
                    .font(.systemFont(ofSize: 14))
            }
        }
        .foregroundColor(.CodeChallenge.white)
    }
}
