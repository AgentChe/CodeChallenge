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
    let programmingLanguage: ProgrammingLanguage
    let aiGenerated: [AIGenerated]?
    let onCodeChange: (String) -> Void

    func makeUIView(context: Context) -> some UIView {
        let vm = PlaygroundViewModel.init(language: programmingLanguage, aiGenerated: aiGenerated ?? [], onCodeChange: onCodeChange)
        let view = PlaygroundView(vm: vm)
        vm.set(code: code ?? "")
//        view.onCodeChange = onCodeChange
//        view.language = programmingLanguage
//        view.set(code: code ?? "")
//        view.aiGenerated = aiGenerated ?? []
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            view.heightAnchor.constraint(equalToConstant: bottomInset)
        ])
        view.setNeedsLayout()
        view.layoutIfNeeded()
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let specialCharacter = specialCharacter {
            (uiView as? PlaygroundView)?.onSelect(specialCharacter: specialCharacter)
        }

        if let resettedTemplate = resettedTemplate {
            (uiView as? PlaygroundView)?.reset(newCode: resettedTemplate)
        }
    }
}
