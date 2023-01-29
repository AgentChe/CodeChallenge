//
//  PremiumCoordinator.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation
import UIKit
import SwiftUI

class PremiumCoordinator {
    let navigationController = UINavigationController()
    let store: Store
    private var popupController: PopupViewController?

    init(store: Store) {
        self.store = store
        let premiumView = PremiumView(onShowAllPlans: { [weak self] payments in
            self?.showAllPlans(payments: payments)
        })
            .environmentObject(store)
        let controller = UIHostingController(rootView: premiumView)
        let tabBarItem = UITabBarItem(
            title: "Premium",
            image: UIImage(named: "premiumTabIcon")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "premiumTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
    }

    private func showAllPlans(payments: [AppStorePayment]) {
        guard let monthly = (payments.first { $0.productIdentifier == "monthly_subscription" }),
        let yearly = (payments.first { $0.productIdentifier == "yearly_pro_2week_trial" }) else { return }
        let monthlyPayment = monthly.price.stringValue
        let yearlyPayment = yearly.price.stringValue
        let products = [
            AppStoreProduct(name: "Monthly", value: monthlyPayment, description: "Billed & Recurring Monthly", payment: monthly),
            AppStoreProduct(name: "Yearly", value: yearlyPayment, description: "Billed & Recurring Yearly", payment: yearly)
        ]
        let view = PremiumAllPlansView(products: products, store: store)
        view.onPurchaseProduct = { [weak self] product in
            self?.store.dispatch(PurchasePayment(payment: product.payment))
        }
        view.onDismiss = { [weak self] in
            self?.popupController?.hide()
        }
        popupController = PopupViewController(contentView: view)
        view.translatesAutoresizingMaskIntoConstraints = false
        if let rootController = UIApplication.shared.windows.first?.rootViewController {
            popupController?.present(from: rootController, bottomOffset: 0)
        }
    }
}
