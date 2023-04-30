//
//  QuizSelectionView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 02/04/2023.
//

import Foundation
import SwiftUI

struct QuizSelectionView: View {
    let text: String
    let options: [String]
    let winning: [String]
    let passed: Bool
    let onSelect: ([String]) -> Void
    @State private var selectedOptions: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(text)
                .font(.regular(size: 18))
                .multilineTextAlignment(.leading)
                .padding(.bottom, 5)

            ForEach(options, id: \.self) { option in
                HStack {
                    Text(option)
                        .foregroundColor(.white)
                        .font(.regular(size: 16))
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    if selectedOptions.contains(option) || (passed && winning.contains(option)) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.CodeChallenge.lessonQuizBlue))
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.CodeChallenge.blue1), lineWidth: 2)
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.CodeChallenge.lessonQuizBlue))
                    }
                }
                .onTapGesture {
                    if selectedOptions.contains(option) {
                        selectedOptions = selectedOptions.filter { $0 != option }
                    } else {
                        selectedOptions.append(option)
                    }
                    onSelect(selectedOptions)
                }
            }
        }
        .padding(.horizontal, 22)
        .disabled(passed)
        .onAppear {
            if passed {
                onSelect(winning)
            }
        }
    }
}
