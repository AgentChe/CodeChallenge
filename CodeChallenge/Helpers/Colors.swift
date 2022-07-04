//
//  Colors.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import UIKit
import SwiftUI

extension UIColor {
    struct CodeChallenge {}
}

extension UIColor.CodeChallenge {
    static var white: UIColor {
        UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    }
    static var black: UIColor {
        UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
    }

    static var dark: UIColor {
        UIColor(red: 24/255, green: 25/255, blue: 30/255, alpha: 1.0)
    }

    static var blue1: UIColor {
        UIColor(red: 37/255, green: 108/255, blue: 252/255, alpha: 1)
    }
}

extension Color {
    static var dark: Color {
        Color(red: 24/255, green: 25/255, blue: 30/255)
    }
}
