//
//  ViewAdditions.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import UIKit
import SwiftUI

extension View {
    @inlinable func foregroundColor(_ color: UIColor) -> some View {
        foregroundColor(Color(color))
    }

    @inlinable func background(_ color: UIColor) -> some View {
        background(Color(color))
    }

    @inlinable func font(_ font: UIFont) -> some View {
        self.font(Font(font as CTFont))
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Text {
    @inlinable func font(_ font: UIFont) -> Text {
        self.font(Font(font as CTFont))
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
