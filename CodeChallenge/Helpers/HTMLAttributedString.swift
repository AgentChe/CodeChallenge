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
    let foregroundColor: UIColor?
    var inset: Int = 40

    func makeUIView(context: UIViewRepresentableContext<Self>) -> ViewWithLabel {
        let view = ViewWithLabel(frame: .zero, inset: inset)
        return view
    }
    func updateUIView(_ uiView: ViewWithLabel, context: Context) {
        htmlAttributedString.addAttributes(
            [NSAttributedString.Key.font: UIFont.regular(size: 18)],
            range: NSRange(location: 0, length: htmlAttributedString.length)
        )
        if let foregroundColor = foregroundColor {
            htmlAttributedString.addAttributes([NSAttributedString.Key.foregroundColor: foregroundColor], range: NSRange(location: 0, length: htmlAttributedString.length))
        }
        uiView.setString(htmlAttributedString)
    }
}

class ViewWithLabel : UIView {
    private var label = UILabel()
    let inset: Int

    init(frame: CGRect, inset: Int) {
        self.inset = inset
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
        label.sizeThatFits(CGSize(width: Int(.screenWidth) - inset, height: 9999))
    }
}
