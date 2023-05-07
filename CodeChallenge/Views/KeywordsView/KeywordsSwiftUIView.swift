//
//  KeywordsSwiftUIView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/08/2022.
//

import Foundation
import UIKit
import SwiftUI

struct KeywordsSwiftUIView: View {
    let keywords: [String]
    let onKeywordTap: (String) -> Void
    @State private var keywordsHeight: Double = 100

    var body: some View {
        KeywordsVieww(keywords: keywords, identifier: "default", onHeightChange: { height in
            keywordsHeight = height
        }, onKeywordTap: onKeywordTap)
        .background(.clear)
        .frame(height: keywordsHeight)
    }
}

fileprivate struct KeywordsVieww: UIViewRepresentable {
    let keywords: [String]
    let identifier: String
    let onHeightChange: ((Double) -> Void)?
    let onKeywordTap: (String) -> Void

    func makeUIView(context: Context) -> some UIView {
        let view = KeywordsView(keywords: keywords, cellIdentifier: identifier)
        view.onHeightChange = onHeightChange
        view.onKeywordTap = onKeywordTap
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        ])
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        (uiView as? KeywordsView)?.update(keywords: keywords)
    }
}
