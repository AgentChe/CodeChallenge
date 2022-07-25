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
    static var navbarBackgroundHeight: CGFloat { UIDevice.hasDisplayNotch ? 240 : 76 }
}

extension UIDevice {
    static var hasDisplayNotch: Bool {
        (UIWindow.main?.safeAreaInsets.top ?? 0) > 20
    }

    static var hasSmallScreen: Bool {
        return (UIWindow.main?.bounds.height ?? 0) <= 667
    }
}

extension UIWindow {
    static var main: UIWindow? {
        let scene = UIApplication.shared.connectedScenes.first { $0 is UIWindowScene } as? UIWindowScene
        return scene?.windows.first
    }
}
