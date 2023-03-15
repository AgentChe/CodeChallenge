//
//  PlaceholderAnimation.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/03/2023.
//

import Foundation
import SwiftUI

struct AnimatePlaceholderModifier: AnimatableModifier {
    @State private var isAnim: Bool = false
    private var center = (UIScreen.main.bounds.width / 2) + 110
    private let animation: Animation = .linear(duration: 1.5)

    func body(content: Content) -> some View {
        content.overlay(animView.mask(content))
    }

    var animView: some View {
        ZStack {
            Color.black.opacity(0.09)
            Color.white.mask(
                Rectangle()
                    .fill(
                        LinearGradient(gradient: .init(colors: [.clear, .white.opacity(0.48), .clear]), startPoint: .top , endPoint: .bottom)
                    )
                    .scaleEffect(1.5)
                    .rotationEffect(.init(degrees: 70.0))
                    .offset(x: isAnim ? center : -center)
            )
        }
        .animation(animation.repeatForever(autoreverses: false), value: isAnim)
        .onAppear {
            isAnim.toggle()
        }
    }
}

extension View {
    func animatePlaceholder() -> some View {
        self.modifier(AnimatePlaceholderModifier())
    }
}
