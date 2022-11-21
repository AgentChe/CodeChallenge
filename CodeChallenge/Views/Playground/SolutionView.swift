//
//  SolutionView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/08/2022.
//

import Foundation
import UIKit
import Highlightr

class SolutionView: UIView, PopupContentView {
    var onDismiss: (() -> Void)?
    private let label = UILabel()
    private let solutionTextView = UITextView()
    private let solution: String

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()

    init(solution: String) {
        self.solution = solution
        super.init(frame: .zero)
        setupViews()
    }

    override var intrinsicContentSize: CGSize {
        return .init(width: UIScreen.main.bounds.width, height: label.intrinsicContentSize.height + 143)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -45),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            solutionTextView.heightAnchor.constraint(equalToConstant: 200)
        ])

        label.text = "Solution"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.textColor = .CodeChallenge.purple
        label.textAlignment = .center

        if let highlightr = Highlightr() {
            highlightr.setTheme(to: "atom-one-dark-reasonable")
            let highlightedCode = highlightr.highlight(solution, as: "python")
            solutionTextView.attributedText = highlightedCode
        }
        solutionTextView.setContentHuggingPriority(.required, for: .vertical)
        solutionTextView.textColor = .white

        solutionTextView.backgroundColor = .CodeChallenge.dark
        solutionTextView.layer.cornerRadius = 10
        solutionTextView.isEditable = false

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(solutionTextView)

        backgroundColor = .CodeChallenge.background
        layer.cornerRadius = 20
    }
}
