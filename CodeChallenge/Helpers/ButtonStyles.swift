//
//  ButtonStyles.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import Foundation
import SwiftUI

struct PrimaryButton: ButtonStyle {
    enum Status: String, Equatable {
        case enabled, loading, disabled
    }
    var status = Status.enabled

    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            if status == .loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            HStack {
                Spacer()
                configuration.label
                    .padding(.vertical, 15)
                    .opacity(status == .loading ? 0 : 1)
                Spacer()
            }
        }
        .frame(height: 56)
        .foregroundColor(status == .enabled ? .white : .CodeChallenge.whiteDisabled)
        .background(status == .enabled ? .CodeChallenge.blue1 : .CodeChallenge.blueDiabled)
        .font(.button)
        .clipShape(Capsule())
    }
}

struct GradientButton: ButtonStyle {
    enum Status: String, Equatable {
        case enabled, loading, disabled
    }
    var status = Status.enabled

    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            if status == .loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            HStack {
                Spacer()
                configuration.label
                    .padding(.vertical, 15)
                    .opacity(status == .loading ? 0 : 1)
                Spacer()
            }
        }
        .frame(height: 56)
        .foregroundColor(status == .enabled ? .white : .CodeChallenge.whiteDisabled)
        .modifier(PremiumGradientModifier())
        .font(.button)
    }
}

extension UIButton {
    func applyGradient(colors: [CGColor]) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.frame.height/2

        gradientLayer.shadowColor = UIColor.darkGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 0.3
        gradientLayer.masksToBounds = false

        self.layer.insertSublayer(gradientLayer, at: 0)
        self.contentVerticalAlignment = .center
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        self.titleLabel?.textColor = UIColor.white
    }
}

struct PremiumGradientModifier: ViewModifier {
    var changeStrokeColor: Bool = false
    var cornerRadius: Int = 0
    var corners: UIRectCorner = [.allCorners]

    func body(content: Content) -> some View {
        if changeStrokeColor {
            content
                .background {
                    RoundedRectangle(cornerRadius: CGFloat(cornerRadius))
                    .stroke (
                        LinearGradient(
                            gradient: .init(colors: [Color(UIColor.CodeChallenge.blue1), Color(.CodeChallenge.purple)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ), style: StrokeStyle(lineWidth: 1)
                    )
                    .background {
                        RoundedRectangle(cornerRadius: CGFloat(cornerRadius))
                            .fill(Color(UIColor.CodeChallenge.dark))
                    }
                }
        } else {
            content
                .background {
                    LinearGradient(
                        gradient: .init(colors: [Color(UIColor.CodeChallenge.blue1), Color(.CodeChallenge.purple)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        RoundedCornersShape(corners: corners,
                                            radius: CGFloat(cornerRadius))
                            .clipShape(Capsule())
                    )
                }
        }
    }
}
