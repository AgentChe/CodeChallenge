//
//  LottieFile.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 26/01/2023.
//

import Foundation
import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    let lottieFile: String

    let animationView = AnimationView()

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)

        animationView.animation = Animation.named(lottieFile)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()

        view.addSubview(animationView)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let view = (uiView as? UIView) else { return }
        view.subviews.compactMap { $0 as? AnimationView }.first?.play()
    }
}
