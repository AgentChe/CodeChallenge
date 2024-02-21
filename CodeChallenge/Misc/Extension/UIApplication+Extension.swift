//
//  UIApplication+Extension.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 21.02.2024.
//

import UIKit

extension UIApplication {
    func getTopViewController(base: UIViewController? = shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
