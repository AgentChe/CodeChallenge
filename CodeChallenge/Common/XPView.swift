//
//  XPView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 28/08/2022.
//

import Foundation
import SwiftUI

struct DefaultXPView: View {
    let xpText: String
    let backgroundColor: UIColor
    let xpIconColor: String
    let strokeColor: UIColor?

    var body: some View {
        if let strokeColor = strokeColor {
            content
                .background(
                    RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(strokeColor), lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(backgroundColor)))
                )
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: 16)
                    .fill(Color(backgroundColor))
                )
        }
    }

    private var content: some View {
        HStack(spacing: 4) {
            Text(xpText)
                .foregroundColor(.white)
                .font(.h5)
            Image("xpIcon_\(xpIconColor)")
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .frame(height: 32)
    }
}

struct AccountPremiumXPView: View {
    let xpText: String

    var body: some View {
        HStack(spacing: 4) {
            Text(xpText)
                .foregroundColor(.white)
                .font(.h5)
            Image("xpIcon_white")
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .frame(height: 32)
        .modifier(PremiumGradientModifier(changeStrokeColor: true, cornerRadius: 16))
    }
}

struct ChallengeDefaultXPView: View {
    let xpText: String

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(.CodeChallenge.white), lineWidth: 1)
            )
    }

    private var content: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 4)
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: 8)
                Text(xpText)
                    .foregroundColor(.white)
                    .font(.tag)
                Spacer()
                    .frame(width: 2)
                Image("xpIcon_white")
                Spacer()
                    .frame(width: 8)
            }
            Spacer()
                .frame(height: 4)
        }
    }
}

struct ChallengePremiumXPView: View {
    let xpText: String

    var body: some View {
        content
            .modifier(PremiumGradientModifier(cornerRadius: 10))
            .padding(3.5)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.CodeChallenge.xpGrayishBackground))
            }
    }

    private var content: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 4)
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: 8)
                Text(xpText)
                    .foregroundColor(.white)
                    .font(.tag)
                Spacer()
                    .frame(width: 2)
                Image("challenge_premium_icon")
                Spacer()
                    .frame(width: 8)
            }
            Spacer()
                .frame(height: 4)
        }
    }
}
