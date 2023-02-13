//
//  UniversalCodeChallengeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 21/08/2022.
//

import Foundation
import SwiftUI

struct UniversalCodeChallengeView: View {
    @EnvironmentObject var store: Store
    let codeChallenge: Challenge

    var body: some View {
        if codeChallenge.isPremium && codeChallenge.progress == "done" {
            itemView
                .modifier(PremiumGradientModifier(changeStrokeColor: true, cornerRadius: 10))
        } else {
            if codeChallenge.progress != "done" {
                itemView
                    .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.CodeChallenge.gray))
                )
            } else {
                itemView
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(UIColor.CodeChallenge.blue1))
                            .background(.CodeChallenge.dark)
                    )
            }
        }
    }

    @ViewBuilder
    private var itemView: some View {
        HStack(spacing: 10) {
            VStack {
                Spacer()
                NetworkImage(
                    viewModel: .init(url: "\(Configuration.host)/challange/getImage/\(codeChallenge.id)/",
                                     store: store,
                                     placeholder: .init(named: "placeholder_image")),
                    size: .init(width: 40, height: 40)
                )
                Spacer()
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(codeChallenge.name)
                        .lineLimit(2)
                        .padding(.top, 5)
                        .foregroundColor(.white)
                        .font(.bodyText)
                    Spacer()
                    if codeChallenge.isPremium == true {
                        if codeChallenge.progress == "done" {
                            Image("premium_challenge_progress_done")
                        } else {
                            ChallengePremiumXPView(xpText: "\(codeChallenge.xp)")
                        }
                    } else if codeChallenge.progress == "inprogress" {
                        ChallengeDefaultXPView(xpText: "\(codeChallenge.xp)")
                    } else if codeChallenge.progress == "done" {
                        Image("challenge_progress_done")
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    ForEach(Array(codeChallenge.allTags.prefix(3)), id: \.self) {
                        Button($0.name) {}
                            .buttonStyle(RoundedButtonStyle(foregroundColor: .white, backgroundColor: UIColor(hexString: "#\($0.color.components(separatedBy: "#").last ?? "")")))
                    }
                }
                .frame(height: 18)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(height: 80)
    }
}
