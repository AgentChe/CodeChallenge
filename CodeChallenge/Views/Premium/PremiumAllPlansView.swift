//
//  PremiumAllPlansView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 04/08/2022.
//

import Foundation
import UIKit

struct AppStoreProduct: Equatable {
    let name: String
    let value: String
    let description: String
}

class PremiumAllPlansView: UIView, PopupContentView {
    var onDismiss: (() -> Void)?
    let products: [AppStoreProduct]
    var selectedProduct: AppStoreProduct? {
        didSet {
            setupChildViews()
        }
    }
    private var hStack: UIStackView?
    private let label = UILabel()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 30
        return stackView
    }()

    init(products: [AppStoreProduct]) {
        self.products = products
        self.selectedProduct = products.last
        super.init(frame: .zero)
        setupViews()
    }

    override var intrinsicContentSize: CGSize {
        return .init(width: UIScreen.main.bounds.width, height: label.intrinsicContentSize.height + 273)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 40),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -73),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25)
        ])
        setupChildViews()
    }

    func setupChildViews() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        label.text = "All premium plans"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.textColor = .white

        stackView.addArrangedSubview(label)
        setupProducts()

        backgroundColor = .CodeChallenge.dark

        let button = UIButton()
        button.setTitle("Start 7 Day Trial Now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        stackView.addArrangedSubview(button)
        button.backgroundColor = .CodeChallenge.blue1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25

        let noThanksButton = UIButton()
        noThanksButton.setTitle("NO THANKS", for: .normal)
        noThanksButton.setTitleColor(.white, for: .normal)
        noThanksButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        stackView.addArrangedSubview(noThanksButton)
        noThanksButton.translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 20

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 50),
            noThanksButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 50),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupProducts() {
        if hStack == nil {
            hStack = UIStackView()
        }
//        hStack?.translatesAutoresizingMaskIntoConstraints = false
        hStack?.arrangedSubviews.forEach { $0.removeFromSuperview() }
        hStack?.spacing = 20
        hStack?.axis = .horizontal

        products.forEach { product in
            let productView = ProductView(product: product, isSelected: product == selectedProduct)
            productView.translatesAutoresizingMaskIntoConstraints = false
            productView.onSelect = { [weak self] isSelected in
                self?.selectedProduct = product
            }
            NSLayoutConstraint.activate([
                productView.heightAnchor.constraint(equalToConstant: 182.5),
                productView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2 - 35)
            ])
            hStack?.addArrangedSubview(productView)
        }
        stackView.addArrangedSubview(hStack!)
//        stackView.addArrangedSubview(UIView())
    }
}

fileprivate class ProductView: UIView {
    var product: AppStoreProduct?
    var onSelect: ((Bool) -> Void)?
    var isSelected: Bool

    init(product: AppStoreProduct?, isSelected: Bool) {
        self.product = product
        self.isSelected = isSelected
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        let label1 = UILabel()
        let label2 = UILabel()
        let label3 = UILabel()
        label1.text = product?.name
        label1.font = .systemFont(ofSize: 18, weight: .medium)
        label2.text = product?.value
        label2.font = .systemFont(ofSize: 20, weight: .bold)
        label3.text = product?.description
        label3.font = .systemFont(ofSize: 14, weight: .regular)
        label1.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label2.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label3.numberOfLines = 3
        label3.textAlignment = .center

        [label1, label2, label3].forEach { $0.textColor = .white }
        [label1, label2, label3].forEach { stack.addArrangedSubview($0) }

        addSubview(stack)
        self.layer.cornerRadius = 10

        backgroundColor = .CodeChallenge.background

        let action = UIAction(handler: { [weak self] _ in
            self?.onSelect?(self?.isSelected == false)
        })
        let overlayButton = UIButton(primaryAction: action)
        overlayButton.backgroundColor = .clear
        overlayButton.translatesAutoresizingMaskIntoConstraints = false

        if isSelected {
            let backgroundView = UIView()
            backgroundView.layer.cornerRadius = 10
            backgroundView.backgroundColor = .CodeChallenge.background
            backgroundView.translatesAutoresizingMaskIntoConstraints = false

            backgroundView.layer.borderColor = UIColor.CodeChallenge.blue1.cgColor
            backgroundView.layer.borderWidth = 3

            let button = UIButton()
            button.setImage(UIImage(named: "premium_checkmark"), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(button)
            self.addSubview(backgroundView)
            self.sendSubviewToBack(backgroundView)

            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 12.5),
                button.heightAnchor.constraint(equalToConstant: 25),
                button.widthAnchor.constraint(equalToConstant: 25),
                backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            ])
        }

        self.addSubview(overlayButton)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor, constant: 25),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 17),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -17),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12.5),
            overlayButton.topAnchor.constraint(equalTo: self.topAnchor),
            overlayButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            overlayButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            overlayButton.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}
