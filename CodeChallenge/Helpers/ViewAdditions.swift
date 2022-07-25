//
//  ViewAdditions.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import UIKit
import SwiftUI
import Combine

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

struct RoundedCornersShape: Shape {
    let corners: UIRectCorner
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
  var keyboardPublisher: AnyPublisher<CGFloat, Never> {
    Publishers
      .Merge(
        NotificationCenter
          .default
          .publisher(for: UIResponder.keyboardWillShowNotification)
          .map {
              if let keyboardFrame: NSValue = $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                      let keyboardRectangle = keyboardFrame.cgRectValue
                      let keyboardHeight = keyboardRectangle.height
                  return keyboardHeight
                  }
              return 0
          },
        NotificationCenter
          .default
          .publisher(for: UIResponder.keyboardWillHideNotification)
          .map { _ in return 0 })
      .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
      .eraseToAnyPublisher()
  }
}
