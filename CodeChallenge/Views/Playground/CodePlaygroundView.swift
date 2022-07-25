//
//  CodePlaygroundView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 23/07/2022.
//

import Foundation
import SwiftUI

struct CodePlaygroundView: UIViewRepresentable {
    @Binding var specialCharacter: String?
    @Binding var code: String?
    @Binding var resettedTemplate: String?
    let bottomInset: CGFloat
    let onCodeChange: (String) -> Void

    func makeUIView(context: Context) -> some UIView {
        let view = PlaygroundView(frame: .zero)
        view.onCodeChange = onCodeChange
        view.set(code: code ?? "")
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            view.heightAnchor.constraint(equalToConstant: bottomInset)
        ])
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let specialCharacter = specialCharacter {
            (uiView as? PlaygroundView)?.onSelect(specialChar: specialCharacter)
        }

        if let resettedTemplate = resettedTemplate {
            (uiView as? PlaygroundView)?.reset(newCode: resettedTemplate)
        }
    }
}
