//
//  GenerateWithAIView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 12/03/2023.
//

import Foundation
import SwiftUI

struct GenerateWithAIView: View {
    let onSelect: (() -> Void)
    @State private var isLoading: Bool = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                Image("ai")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
        .onTapGesture {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isLoading = false
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background {
            RoundedCornersShape(corners: [.topLeft, .bottomLeft], radius: 18)
                .fill(Color(UIColor.CodeChallenge.blue1))
        }
    }
}

struct AskAIView: View {
    let onSelect: (() -> Void)

    var body: some View {
        HStack {
            Image("ai")
                .resizable()
                .frame(width: 36, height: 36)
            Text("Ask AI")
                .padding(.vertical, 12)
                .font(.h4)
                .foregroundColor(.white)
        }
        .onTapGesture {
            onSelect()
        }
        .padding(.horizontal, 12)
        .background {
            RoundedCornersShape(corners: [.topLeft, .bottomLeft], radius: 20)
                .fill(Color(UIColor.CodeChallenge.blue1))
        }
    }
}
