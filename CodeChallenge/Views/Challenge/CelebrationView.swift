//
//  CelebrationView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 28/08/2022.
//

import Foundation
import UIKit
import SwiftUI
import Lottie

class CelebrationView: UIView, PopupContentView {
    let store: Store
    var onDismiss: (() -> Void)?

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 30
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    private let iconImageView = NetworkImageView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .h2
        return label
    }()

    private let describtionLabel: UILabel = {
        let label = UILabel()
        label.text = "Code Challenge is Solved"
        label.textColor = .white
        label.font = .regular(size: 16)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.textAlignment = .center
        return label
    }()

    private let rewardBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.CodeChallenge.blue1.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    private let continueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .CodeChallenge.blue1
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .button
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()

    init(challenge: ChallengeDetail, store: Store) {
        self.store = store
        super.init(frame: .zero)
        setupViews(challenge: challenge)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.runConfetti()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews(challenge: ChallengeDetail) {
        self.backgroundColor = .CodeChallenge.dark
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        iconImageView.bind(to: .init(url: "\(Configuration.host)/challange/getImage/\(challenge.id)/", store: store))
        [iconImageView, titleLabel, describtionLabel, rewardBackgroundView, continueButton].forEach { stackView.addArrangedSubview($0) }
        continueButton.addTarget(self, action: #selector(handleContinueTap), for: .touchUpInside)
        drawRewardView(challenge: challenge)
        self.titleLabel.text = "\(challenge.name) is solved!"
        self.describtionLabel.text = "The only time you should ever look back is to see how far you've come. Just continue practicing!"

        layer.cornerRadius = 20

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 25),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            iconImageView.heightAnchor.constraint(equalToConstant: 120),
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            rewardBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            rewardBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            continueButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            continueButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25)
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc private func handleContinueTap() {
        onDismiss?()
    }

    private func drawRewardView(challenge: ChallengeDetail) {
        let label = UILabel()
        label.textColor = .white
        label.font = .h4
        label.text = "Your reward:"

        let xpView = XPView(xpText: "+\(challenge.xp)", backgroundColor: .CodeChallenge.background, xpIconColor: "blue", strokeColor: nil)
        let xpViewController = UIHostingController(rootView: xpView)
        let xpUIView = xpViewController.view
        xpUIView?.backgroundColor = .clear

        let stackView = UIStackView()
        stackView.spacing = 15
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center

        [label, xpUIView].compactMap { $0 }.forEach {
            stackView.addArrangedSubview($0)
        }

        rewardBackgroundView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: rewardBackgroundView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: rewardBackgroundView.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: rewardBackgroundView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: rewardBackgroundView.trailingAnchor)
        ])
    }

    private func runConfetti() {
        let jsonName = "confetti"
        let animation = Animation.named(jsonName)

        // Load animation to AnimationView
        let animationView = AnimationView(animation: animation)
        self.addSubview(animationView)
        self.setNeedsLayout()
        self.layoutIfNeeded()
        animationView.frame = .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.frame.size.height)
        animationView.play()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3, animations: {
                animationView.alpha = 0
            }, completion: { _ in
                animationView.removeFromSuperview()
            })
        }
    }
}

