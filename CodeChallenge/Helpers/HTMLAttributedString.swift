//
//  HtmlAttributedLabel.swift
//  Maisonette
//
//  Created by Tatevik Tovmasyan on 24/08/2022.
//

import Foundation
import SwiftUI

struct HtmlAttributedLabel: UIViewRepresentable {
    let htmlAttributedString: NSMutableAttributedString

    func makeUIView(context: UIViewRepresentableContext<Self>) -> ViewWithLabel {
        let view = ViewWithLabel(frame: .zero)
        return view
    }
    func updateUIView(_ uiView: ViewWithLabel, context: Context) {
        htmlAttributedString.addAttributes(
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
             NSAttributedString.Key.foregroundColor: UIColor.white],
            range: NSRange(location: 0, length: htmlAttributedString.length)
        )
        uiView.setString(htmlAttributedString)
    }
}

class ViewWithLabel : UIView {
    private var label = UILabel()

    override init(frame: CGRect) {
        super.init(frame:frame)
        self.addSubview(label)
        label.numberOfLines = 0
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setString(_ attributedString:NSAttributedString) {
        self.label.attributedText = attributedString
    }

    override var intrinsicContentSize: CGSize {
        label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 40, height: 9999))
    }
}
