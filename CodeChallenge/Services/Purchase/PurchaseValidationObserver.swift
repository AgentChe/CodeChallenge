//
//  PurchaseValidationObserver.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 20.02.2024.
//

import OtterScaleiOS
import RxSwift
import RxCocoa

final class PurchaseValidationObserver {
    static let shared = PurchaseValidationObserver()
    
    private lazy var trigger = PublishRelay<Void>()
    
    private init() {}
    
    func startObserve() {
        OtterScale.shared.addReceiptValidation(delegate: self)
    }
}

// MARK: OtterScaleReceiptValidationDelegate
extension PurchaseValidationObserver: OtterScaleReceiptValidationDelegate {
    func otterScaleDidValidatedReceipt(with result: AppStoreValidateResult?) {
        trigger.accept(Void())
    }
}

// MARK: Public
extension PurchaseValidationObserver {
    var didValidatedWithActiveSubscription: Signal<Void> {
        trigger.asSignal()
    }
}
