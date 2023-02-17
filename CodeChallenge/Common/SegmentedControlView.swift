//
//  SegmentedControlView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/02/2023.
//

import Foundation
import SwiftUI

struct SegmentedControlView: UIViewRepresentable {
    @Binding var selection: Int
    let sections: [String]
    let onValueChange: (Int) -> Void

    func makeUIView(context: Context) -> some UIView {
        let view = SegmentedControlUIView(
            sections: sections, onValueChange: onValueChange
        )
        view.heightAnchor.constraint(equalToConstant: 31).isActive = true
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 50).isActive = true
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        (uiView as? SegmentedControlUIView)?.segmentedControl.selectedSegmentIndex = selection
    }
}

fileprivate class SegmentedControlUIView: UIView {
    let sections: [String]
    let onValueChange: (Int) -> Void
    var segmentedControl: UISegmentedControl!

    override init(frame: CGRect) {
        self.sections = []
        self.onValueChange = { _ in }
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        self.sections = []
        self.onValueChange = { _ in }
        super.init(coder: coder)
    }

    init(sections: [String],
         onValueChange: @escaping (Int) -> Void) {
        self.sections = sections
        self.onValueChange = onValueChange
        super.init(frame: .zero)
        commonInit()
    }

    func commonInit() {
        segmentedControl = UISegmentedControl(items: sections)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = UIColor.CodeChallenge.blue1
        segmentedControl.backgroundColor = UIColor.CodeChallenge.dark
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)

        segmentedControl.addTarget(self, action: #selector(changedValue(segmentedControl:)), for: .valueChanged)
        self.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: self.topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

    @objc private func changedValue(segmentedControl: UISegmentedControl) {
        onValueChange(segmentedControl.selectedSegmentIndex)
    }
}
