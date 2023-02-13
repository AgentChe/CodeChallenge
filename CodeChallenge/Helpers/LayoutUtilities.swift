//
//  LayoutUtilities.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import UIKit

extension CGFloat {
    static var screenWidth: CGFloat { UIScreen.main.bounds.size.width }
    static var screenHeight: CGFloat { UIScreen.main.bounds.size.height }
    static var navbarBackgroundHeight: CGFloat { 240 }
}

extension UIDevice {
    static var hasDisplayNotch: Bool {
        (UIApplication.shared.mainWindow?.safeAreaInsets.top ?? 0) > 20
    }

    static var hasSmallScreen: Bool {
        return (UIApplication.shared.mainWindow?.bounds.height ?? 0) <= 667
    }
}
