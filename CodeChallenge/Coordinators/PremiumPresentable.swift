//
//  PremiumPresentable.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 16/04/2023.
//

import Foundation
import UIKit
import SwiftUI

protocol PremiumPresentable: AnyObject {
    var store: Store { get }
    var premiumPopupController: PopupViewController? { get set }
}

extension PremiumPresentable {
    func presentPremiumScreen(from navigationController: UINavigationController) {
        let premiumView = PremiumView(onShowAllPlans: { [weak self] payments in
            self?.showAllPlans(payments: payments)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: premiumView)
        navigationController.present(controller, animated: true)
    }

    private func showAllPlans(payments: [AppStorePayment]) {
        guard let monthly = (payments.first { $0.productIdentifier == "monthly_subscription" }),
        let yearly = (payments.first { $0.productIdentifier == "yearly_pro_2week_trial" }) else { return }
        let monthlyPayment = monthly.price.stringValue
        let yearlyPayment = yearly.price.stringValue
        let products = [
            AppStoreProduct(name: "Monthly", value: monthlyPayment, description: "Access 100+ Premium coding challenges. Billed and Recurring Monthly.", payment: monthly),
            AppStoreProduct(name: "Yearly", value: yearlyPayment, description: "Access 100+ Premium coding challenges. Billed and Recurring Yearly.", payment: yearly)
        ]
        let view = PremiumAllPlansView(products: products, store: store)
        view.onPurchaseProduct = { [weak self] product in
            self?.store.dispatch(PurchasePayment(payment: product.payment))
        }
        view.onDismiss = { [weak self] in
            self?.premiumPopupController?.hide()
        }
        premiumPopupController = PopupViewController(contentView: view)
        view.translatesAutoresizingMaskIntoConstraints = false
        if let rootController = UIApplication.shared.mainWindow?.rootViewController {
            premiumPopupController?.present(from: rootController, bottomOffset: 0)
        }
    }
}
