//
//  DoodledView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import SwiftUI

struct DoodledView<Content: View, BarContent: View>: View {
    @State private var imageOpacity = 0 as CGFloat
    private let content: Content
    private let barContent: BarContent?
    private let skipOpacityAnimation: Bool

    init(@ViewBuilder content: () -> Content,
         barContent: (() -> BarContent)? = nil, skipOpacityAnimation: Bool = false) {
        self.content = content()
        self.barContent = barContent?()
        self.skipOpacityAnimation = skipOpacityAnimation
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    Image("doodle")
                        .resizable()
                        .accessibilityHidden(true)
                        .aspectRatio(contentMode: .fill)
                        .opacity(skipOpacityAnimation ? 1 : imageOpacity)
                        .animation(
                            .easeIn(duration: 0.5).delay(0.2),
                            value: imageOpacity
                        )

                    if let barContent = barContent {
                        barContent
                    }
                }
                .frame(width: .screenWidth, height: .navbarBackgroundHeight, alignment: .center)
                .clipped()
                .background(.CodeChallenge.dark)
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
            .padding(.top, -50)
            VStack(spacing: 0) {
                content
            }
        }
        .background(Color.dark.edgesIgnoringSafeArea(.all))
        .onAppear {
            imageOpacity = 1
        }
    }
}

extension DoodledView where BarContent == EmptyView {
    init(@ViewBuilder content: () -> Content, skipOpacityAnimation: Bool = false) {
        self.content = content()
        self.barContent = nil
        self.skipOpacityAnimation = skipOpacityAnimation
    }
}
