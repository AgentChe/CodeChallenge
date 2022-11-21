//
//  NewLabelView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 21/11/2022.
//

import Foundation
import SwiftUI

struct NewLabelView: View {
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 10.5)
                    .stroke(Color(.CodeChallenge.purple), lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 10.5).fill(Color(.CodeChallenge.dark)))
            )
    }

    private var content: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 4)
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: 10)
                Text("New")
                    .foregroundColor(.CodeChallenge.purple)
                    .font(.tag)
                Spacer()
                    .frame(width: 10)
            }
            Spacer()
                .frame(height: 4)
        }
        .frame(height: 21)
    }
}
