//
//  QuizComposeCodeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 02/04/2023.
//

import Foundation
import SwiftUI

struct QuizComposeCodeView: View {
    let text: String
    let options: [String]
    let winning: [String]
    let passed: Bool
    let onSelect: ([String]) -> Void
    @State private var selectedOptions: [String] = []

    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .padding([.horizontal, .bottom], 20)
                .font(.regular(size: 18))
                .multilineTextAlignment(.leading)

            ZStack {
                VStack {
                    ForEach(0..<3) { _ in
                        VStack {
                            Spacer()
                                .frame(height: 36)
                            Rectangle()
                                .fill(Color(UIColor.darkGray))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer()
                }
                OptionsView(options: selectedOptions, onHeightChange: { _ in }, onOptionTap: { keyword in
                    selectedOptions = selectedOptions.filter { $0 != keyword }
                    onSelect(selectedOptions)
                })
                .background(.clear)
                .frame(height: .screenHeight/4)
            }

            OptionsView(options: options.filter { !selectedOptions.contains($0) }, onHeightChange: { _ in }, onOptionTap: { keyword in
                selectedOptions = selectedOptions + [keyword]
                onSelect(selectedOptions)
            })
            .background(.clear)
            .frame(height: .screenHeight/4)
        }
        .onAppear {
            if passed {
                selectedOptions = winning
                onSelect(winning)
            }
        }
    }
}

fileprivate struct OptionsView: UIViewRepresentable {
    let options: [String]
    let onHeightChange: ((Double) -> Void)?
    let onOptionTap: (String) -> Void

    func makeUIView(context: Context) -> some UIView {
        let view = KeywordsView(keywords: options, cellIdentifier: "lessonCell")
        view.onHeightChange = onHeightChange
        view.onKeywordTap = onOptionTap
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: .screenWidth),
            view.heightAnchor.constraint(equalToConstant: .screenHeight/4)
        ])
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        (uiView as? KeywordsView)?.update(keywords: options)
    }
}
