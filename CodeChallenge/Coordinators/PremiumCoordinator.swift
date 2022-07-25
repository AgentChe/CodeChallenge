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
            image: UIImage(named: "premiumTabIcon"),
            selectedImage: UIImage(named: "premiumTabIcon")
        )
        controller.tabBarItem = tabBarItem
        navigationController.setViewControllers([controller], animated: false)
    }

    private func showAllPlans(payments: [AppStorePayment]) {
        let monthlyPayment = payments.first { $0.productIdentifier == "monthly_subscription" }?.price.stringValue ?? ""
        let yearlyPayment = payments.first { $0.productIdentifier == "yeary_7day_trial" }?.price.stringValue ?? ""
        let products = [AppStoreProduct(name: "Monthly", value: monthlyPayment, description: "Billed & Recurring Monthly"),
        AppStoreProduct(name: "Yearly", value: yearlyPayment, description: "Only 6.28$/month Billed & recurring yearly")]
        let view = PremiumAllPlansView(products: products)
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
