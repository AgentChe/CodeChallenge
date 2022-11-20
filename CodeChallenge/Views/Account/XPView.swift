//
//  XPView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 28/08/2022.
//

import Foundation
import SwiftUI

struct XPView: View {
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
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 7)
            HStack(spacing: 4) {
                Spacer()
                    .frame(width: 10)
                Text(xpText)
                    .foregroundColor(.white)
                    .font(.systemFont(ofSize: 16))
                Image("xpIcon_\(xpIconColor)")
                Spacer()
                    .frame(width: 10)
            }
            Spacer()
                .frame(height: 7)
        }
        .frame(height: 32)
    }
}

struct ChallengeXPView: View {
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
                .frame(height: 3)
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: 8)
                Text(xpText)
                    .foregroundColor(.white)
                    .font(.systemFont(ofSize: 10))
                Spacer()
                    .frame(width: 2)
                Image("xpIcon_white")
                Spacer()
                    .frame(width: 8)
            }
            Spacer()
                .frame(height: 3)
        }
        .frame(height: 19)
    }
}
