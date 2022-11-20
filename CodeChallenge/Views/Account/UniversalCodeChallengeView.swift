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
        ZStack {
            if codeChallenge.progress == "inprogress" {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.CodeChallenge.gray))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(UIColor.CodeChallenge.blue1))
                    .background(.CodeChallenge.dark)
            }
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
                            .font(.systemFont(ofSize: 14))
                        Spacer()
                        if codeChallenge.progress == "inprogress" {
                            ChallengeXPView(xpText: "\(codeChallenge.xp)")
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
        }
        .frame(height: 80)
    }
}
