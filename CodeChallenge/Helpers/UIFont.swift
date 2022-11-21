//
//  UIFont.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 21/11/2022.
//

import Foundation
import UIKit

extension UIFont {
    static func regular(size: CGFloat) -> UIFont {
        UIFont(name: "SFProText-Regular", size: size)!
    }

    static func bold(size: CGFloat) -> UIFont {
        UIFont(name: "SFProText-Bold", size: size)!
    }

    static func semibold(size: CGFloat) -> UIFont {
        UIFont(name: "SFProText-Semibold", size: size)!
    }

    static func medium(size: CGFloat) -> UIFont {
        UIFont(name: "SFProText-Medium", size: size)!
    }
}

extension UIFont {
    static var pageNameH1: UIFont {
        .semibold(size: 30)
    }

    static var h2: UIFont {
        .bold(size: 24)
    }

    static var h3: UIFont {
        .semibold(size: 20)
    }

    static var h4: UIFont {
        .semibold(size: 18)
    }

    static var h5: UIFont {
        .regular(size: 16)
    }

    static var bodyText: UIFont {
        .regular(size: 14)
    }

    static var smallText: UIFont {
        .regular(size: 12)
    }

    static var tag: UIFont {
        .regular(size: 10)
    }

    static var button: UIFont {
        .medium(size: 18)
    }

    static var tabbar: UIFont {
        .medium(size: 10)
    }
}
