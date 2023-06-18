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

    static var background: UIColor {
        UIColor(red: 39/255, green: 40/255, blue: 44/255, alpha: 1)
    }

    static var gray: UIColor {
        UIColor(red: 39/255, green: 42/255, blue: 51/255, alpha: 1)
    }

    static var purple: UIColor {
        UIColor(red: 128/255, green: 111/255, blue: 255/255, alpha: 1)
    }

    static var gray1: UIColor {
        UIColor(red: 171/255, green: 171/255, blue: 171/255, alpha: 0.1)
    }

    static var gray2: UIColor {
        UIColor(red: 39/255, green: 40/255, blue: 44/255, alpha: 1)
    }

    static var tabBar: UIColor {
        UIColor(red: 25/255, green: 29/255, blue: 41/255, alpha: 1.0)
    }

    static var lightBlue: UIColor {
        UIColor(red: 106/255, green: 143/255, blue: 245/255, alpha: 1.0)
    }
    
    static var lightPurple: UIColor {
        UIColor(red: 143/255, green: 150/255, blue: 248/255, alpha: 1.0)
    }
    
    static var purple2: UIColor {
        UIColor(red: 152/255, green: 108/255, blue: 242/255, alpha: 1.0)
    }

    static var green: UIColor {
        UIColor.init(red: 32/255, green: 187/255, blue: 130/255, alpha: 1.0)
    }

    static var mediumBlue: UIColor {
        UIColor.init(red: 92/255, green: 146/255, blue: 255/255, alpha: 1.0)
    }

    static var tagGreen: UIColor {
        UIColor.init(red: 32/255, green: 187/255, blue: 130/255, alpha: 1.0)
    }

    static var tagYellow: UIColor {
        UIColor.init(red: 255/255, green: 193/255, blue: 105/255, alpha: 1.0)
    }

    static var tagOrange: UIColor {
        UIColor.init(red: 255/255, green: 122/255, blue: 79/255, alpha: 1.0)
    }

    static var blueDiabled: UIColor {
        UIColor.init(red: 28/255, green: 50/255, blue: 97/255, alpha: 1.0)
    }

    static var whiteDisabled: UIColor {
        UIColor.init(red: 119/255, green: 132/255, blue: 160/255, alpha: 1.0)
    }

    static var darkBlue: UIColor {
        UIColor.init(red: 24/255, green: 31/255, blue: 59/255, alpha: 1.0)
    }

    static var dustyBlue: UIColor {
        UIColor.init(red: 56/255, green: 75/255, blue: 114/255, alpha: 1.0)
    }

    static var xpGrayishBackground: UIColor {
        UIColor.init(red: 37/255, green: 38/255, blue: 43/255, alpha: 1.0)
    }

    static var lessonQuizBlue: UIColor {
        UIColor.init(red: 28/255, green: 55/255, blue: 108/255, alpha: 1.0)
    }

    static var lessonQuizGreen: UIColor {
        UIColor.init(red: 40/255, green: 225/255, blue: 157/255, alpha: 1.0)
    }

    static var lessonQuizRed: UIColor {
        UIColor.init(red: 231/255, green: 127/255, blue: 91/255, alpha: 1.0)
    }
}

extension Color {
    static var dark: Color {
        Color(red: 24/255, green: 25/255, blue: 30/255)
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
