//
//  PaywallService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 29/01/2023.
//

import Foundation
import Paywall
import StoreKit

class PaywallService: NSObject {
    let store: Store
    let apiKey = "pk_50c85dfa4780200287f386905ec70e11d300f229d7d8b94e"
    var isPremium: Bool?

    init(store: Store) {
        self.store = store
        super.init()

        let options = PaywallOptions()
        Paywall.configure(
            apiKey: apiKey,
            delegate: self,
            options: options
        )

        store.statePublisher
            .map { $0.account.value?.isPremium }
            .ephemeralSink { [weak self] isPremium in
                self?.isPremium = isPremium
            }
    }
}

// MARK: - Paywall Delegate
extension PaywallService: PaywallDelegate {
  func purchase(product: SKProduct) {
      store.dispatch(PurchasePayment(payment: product))
  }

  func restorePurchases(completion: @escaping (Bool) -> Void) {
      store.dispatch(RestorePurchases(completionBlock: completion))
  }

  func isUserSubscribed() -> Bool {
      return isPremium == true
  }
}
