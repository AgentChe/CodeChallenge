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
//    private var contentViewTopConstraint: NSLayoutConstraint?
    private var contentViewBottomConstraint: NSLayoutConstraint?
    private var cancellables = Set<AnyCancellable>()

    init(contentView: UIView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupKeyboardBinding()
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
//            contentViewTopConstraint = contentView.topAnchor.constraint(equalTo: view.topAnchor)
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

//    private func setupKeyboardBinding() {
//        NotificationCenter.default
//            .publisher(for: UIApplication.keyboardWillShowNotification)
//            .sink(receiveValue: { [weak self] notification in
//                self?.keyboardWillShow(notification)
//            })
//            .store(in: &cancellables)
//
//        NotificationCenter.default
//            .publisher(for: UIApplication.keyboardWillHideNotification)
//            .sink(receiveValue: { [weak self] _ in
//                self?.keyboardWillHide()
//            })
//            .store(in: &cancellables)
//    }
//
//    func keyboardWillShow(_ notification: Notification) {
//        guard let contentView = contentView else { return }
//        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
//
//            let topInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
//            let contentViewTopMargin = -contentView.intrinsicContentSize.height - keyboardHeight
//            contentViewTopConstraint?.constant = min(abs(contentViewTopMargin), UIScreen.main.bounds.height - topInset)
//            contentViewBottomConstraint?.constant = keyboardHeight
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    func keyboardWillHide() {
//        if let contentView = contentView {
//            contentViewTopConstraint?.constant = contentView.intrinsicContentSize.height
//        }
//        contentViewBottomConstraint?.constant = 0
//        UIView.animate(withDuration: 0.3) { [weak self] in
//            self?.view.layoutIfNeeded()
//        }
//    }
}

extension PopupViewController {
    func present(from controller: UIViewController, bottomOffset: CGFloat = 0) {
        self.willMove(toParent: controller)
        controller.addChild(self)
        controller.view.addSubview(self.view)
        self.didMove(toParent: controller)
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: controller.view.topAnchor),
            self.view.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            self.view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor, constant: bottomOffset)
        ])

        if let contentView = contentView {
//            contentViewTopConstraint?.constant = contentView.intrinsicContentSize.height
//            contentViewTopConstraint?.isActive = true
            contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 1000)
            contentViewBottomConstraint?.isActive = true
        }

        UIView.performWithoutAnimation { [weak self] in
            self?.view.layoutIfNeeded()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            if let contentView = contentView {
    //            contentViewTopConstraint?.constant = contentView.intrinsicContentSize.height
    //            contentViewTopConstraint?.isActive = true
            self.contentViewBottomConstraint?.constant = 0
            self.contentViewBottomConstraint?.isActive = true
//            }
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
                self?.opacityView.alpha = 0.7
            }
        }
    }

    func hide() {
//        contentViewTopConstraint?.constant = 0
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
