//
//  SimpleCodePlaygroundView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/04/2023.
//

import Foundation
import UIKit
import SwiftUI
import Highlightr

struct SimpleCodePlaygroundView: UIViewRepresentable {
    let code: String?
    let onCodeUpdate: ((String) -> Void)?

    func makeUIView(context: Context) -> some UIView {
        let view = SimpleCodePlaygroundUIKitView()
        view.set(code: code ?? "")
        view.onCodeUpdate = onCodeUpdate
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        (uiView as? SimpleCodePlaygroundUIKitView)?.set(code: code ?? "")
    }
}

class SimpleCodePlaygroundUIKitView: UIView {
    var onCodeUpdate: ((String) -> Void)?
    let textView: UITextView = {
        let textStorage = CodeAttributedString()
        textStorage.highlightr.setTheme(to: "atom-one-dark-reasonable")
        textStorage.highlightr.theme.setCodeFont(UIFont(name: "CourierNewPSMT", size: 16)!)
        textStorage.language = "python"
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: .init(width: .screenWidth - 40, height: 200))
        layoutManager.addTextContainer(textContainer)

        let textView = UITextView(frame: .zero, textContainer: textContainer)
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.autocapitalizationType = .none
        textView.smartQuotesType = .no
        textView.keyboardType = .asciiCapable
        textView.autocorrectionType = .no
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        self.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self

        NSLayoutConstraint
            .activate([
                textView.topAnchor.constraint(equalTo: self.topAnchor),
                textView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                textView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
    }

    func set(code: String) {
        textView.text = code
    }
}

extension SimpleCodePlaygroundUIKitView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        onCodeUpdate?(updatedText)
        return true
    }
}
