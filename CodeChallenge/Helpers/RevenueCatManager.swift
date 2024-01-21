//
//  RevenueCatManager.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 21/01/2024.
//

import Foundation
import RevenueCat
import SuperwallKit
import StoreKit

class RevenueCatManager: PurchaseController {
    var store: Store?
    static let shared = RevenueCatManager()
    
    func start(with store: Store) {
        self.store = store
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_ZKljbKyCDWiWdokiwREGUBrKlqp")
        Superwall.configure(apiKey: "pk_50c85dfa4780200287f386905ec70e11d300f229d7d8b94e", purchaseController: RevenueCatManager.shared)
        
        store.statePublisher
            .map { $0.account.value?.isPremium }
            .ephemeralSink { [weak self] isPremium in
                guard let isPremium = isPremium else { return }
                self?.syncSubscriptionStatus(isBackendPremium: isPremium)
            }
    }
    
    // MARK: Sync Subscription Status
    /// Makes sure that Superwall knows the customers subscription status by
    /// changing `Superwall.shared.subscriptionStatus`
    func syncSubscriptionStatus(isBackendPremium: Bool) {
        assert(Purchases.isConfigured, "You must configure RevenueCat before calling this method.")
        Task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                // Gets called whenever new CustomerInfo is available
                print("TT___ sync called")
                let hasActiveSubscription = !customerInfo.entitlements.active.isEmpty || isBackendPremium
                store?.dispatch(UpdateUserPremium(premium: hasActiveSubscription))
                if hasActiveSubscription {
                    Superwall.shared.subscriptionStatus = .active
                } else {
                    Superwall.shared.subscriptionStatus = .inactive
                }
            }
        }
    }
    
    // MARK: Handle Purchases
    /// Makes a purchase with RevenueCat and returns its result. This gets called when
    /// someone tries to purchase a product on one of your paywalls.
    func purchase(product: SKProduct) async -> PurchaseResult {
        do {
            // This must be initialized before initiating the purchase.
            let purchaseDate = Date()
            print("TT___ purchase called")
            
            let storeProduct = RevenueCat.StoreProduct(sk1Product: product)
            let revenueCatResult = try await Purchases.shared.purchase(product: storeProduct)
            if revenueCatResult.userCancelled {
                store?.dispatch(UpdateUserPremium(premium: false))
                return .cancelled
            } else {
                store?.dispatch(UpdateUserPremium(premium: true))
                if let transaction = revenueCatResult.transaction,
                   purchaseDate > transaction.purchaseDate {
                    return .restored
                } else {
                    return .purchased
                }
            }
        } catch let error as ErrorCode {
            store?.dispatch(UpdateUserPremium(premium: false))
            if error == .paymentPendingError {
                return .pending
            } else {
                return .failed(error)
            }
        } catch {
            store?.dispatch(UpdateUserPremium(premium: false))
            return .failed(error)
        }
    }
    
    // MARK: Handle Restores
    /// Makes a restore with RevenueCat and returns `.restored`, unless an error is thrown.
    /// This gets called when someone tries to restore purchases on one of your paywalls.
    func restorePurchases() async -> RestorationResult {
        print("TT___ restore called")

        do {
            _ = try await Purchases.shared.restorePurchases()
            store?.dispatch(UpdateUserPremium(premium: true))
            return .restored
        } catch let error {
            store?.dispatch(UpdateUserPremium(premium: false))
            return .failed(error)
        }
    }
    
    func finishTransactions() {
        guard let transaction = SKPaymentQueue.default().transactions.last else {
            return
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        
        // trigger revenuecat sdk to see if the premium is active, update user in backend
        self.syncSubscriptionStatus(isBackendPremium: false)
    }
}
