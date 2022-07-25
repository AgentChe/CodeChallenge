//
//  CodePlaygroundView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 23/07/2022.
//

import Foundation
import SwiftUI

struct CodePlaygroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = PlaygroundView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - 300),
            view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        ])
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
