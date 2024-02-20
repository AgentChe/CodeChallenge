//
//  PaygateViewController.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 20.02.2024.
//

import UIKit
import RxSwift

final class PaygateViewController: UIViewController {
    lazy var mainView = PaygateView()
    
    private lazy var viewModel = PaygateViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: PaygateViewModel.Input(
            didTapClose: mainView.closeButton.rx.tap.asSignal(),
            didTapBuy: mainView.buyButton.rx.tap.asSignal(),
            didTapRestore: mainView.restoreButton.rx.tap.asSignal(),
            didTapTermsAndPolicy: mainView.termsAndPrivacyButton.rx.tap.asSignal()
        ))
        
        output.activity
            .drive(Binder(self) { base, activity in
                base.activity(activity)
            })
            .disposed(by: disposeBag)
        
        output.price
            .drive(Binder(mainView) { base, price in
                base.setup(price: price)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension PaygateViewController {
    static func make() -> PaygateViewController {
        let vc = PaygateViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: Private
private extension PaygateViewController {
    func activity(_ activity: Bool) {
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
        
        mainView.bottomContainer.isHidden = activity
        mainView.restoreButton.isHidden = activity
        mainView.termsAndPrivacyButton.isHidden = activity
        mainView.closeButton.isHidden = activity
    }
    
    func route(_ route: PaygateViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true)
        case .error:
            showError()
        case .open(let url):
            UIApplication.shared.open(url)
        }
    }
    
    func showError() {
        let alert = UIAlertController(title: "Paygate.Error.Title".localized, message: "Paygate.Error.Text".localized, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Paygate.Error.Button".localized, style: .cancel)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
