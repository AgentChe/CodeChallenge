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
        .foregroundColor(.white)
        .background(status == .enabled ? Color.purple : Color.gray)
        .clipShape(Capsule())
    }
}
