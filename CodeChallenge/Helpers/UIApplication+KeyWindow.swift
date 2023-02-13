//
//  UIApplication+KeyWindow.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 11/02/2023.
//

import Foundation
import UIKit

extension UIApplication {
    var mainWindow: UIWindow? {
        let scene = UIApplication.shared.connectedScenes.first { $0 is UIWindowScene } as? UIWindowScene
        return scene?.windows.first
    }
}
