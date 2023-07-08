//
//  PopupViewController.swift
//  Maisonette
//
//  Created by Tatevik Tovmasyan on 11/01/2022.
//

import Foundation
import UIKit
import Combine
import SwiftUI

protocol PopupContentView {
    var onDismiss: (() -> Void)? { get }
}

class PopupViewController: UIViewController {
    private let opacityView: UIView = {
        let view = UIView()
        view.alpha = 0.7
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let contentView: UIView?
    private var contentViewBottomConstraint: NSLayoutConstraint?
    private var cancellables = Set<AnyCancellable>()

    init(contentView: UIView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
        setupViews()
    }

    required init?(coder: NSCoder) {
        self.contentView = nil
        super.init(coder: coder)
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension PopupViewController {
    private func setupViews() {
        if let contentView = contentView {
            view.addSubview(contentView)
            NSLayoutConstraint.activate([
                contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            ])
        }

        view.addSubview(opacityView)
        opacityView.alpha = 0
        NSLayoutConstraint.activate([
            opacityView.topAnchor.constraint(equalTo: view.topAnchor),
            opacityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            opacityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            opacityView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.sendSubviewToBack(opacityView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.opacityView.addGestureRecognizer(tap)
    }

    @objc func handleTap() {
        hide()
    }
}

extension PopupViewController {
    func present(from controller: UIViewController, bottomOffset: CGFloat = 0) {
        controller.view.addSubview(self.view)
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: controller.view.topAnchor),
            self.view.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            self.view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor, constant: bottomOffset)
        ])

        if let contentView = contentView {
            contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 1000)
            contentViewBottomConstraint?.isActive = true
        }

        UIView.performWithoutAnimation { [weak self] in
            self?.view.layoutIfNeeded()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.contentViewBottomConstraint?.constant = 0
            self.contentViewBottomConstraint?.isActive = true
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
                self?.opacityView.alpha = 0.7
            }
        }
    }

    func hide() {
        contentViewBottomConstraint?.constant = 1000
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            self?.opacityView.alpha = 0
        }, completion: { [weak self] _ in
            self?.view.removeFromSuperview()
            self?.removeFromParent()
        })
    }
}
