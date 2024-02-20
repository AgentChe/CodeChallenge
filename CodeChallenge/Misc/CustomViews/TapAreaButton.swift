//
//  TapAreaButton.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 20.02.2024.
//

import UIKit

class TapAreaButton: UIButton {
    var dx: CGFloat = -10.scale
    var dy: CGFloat = -10.scale
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: dx, dy: dy).contains(point)
    }
}
