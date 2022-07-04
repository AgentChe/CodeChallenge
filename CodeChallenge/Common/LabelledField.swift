//
//  LabelledField.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import SwiftUI

struct LabelledField: View {
    @Binding var text: String
    var title: String = ""
    var isSecure: Bool = false
    var status: Status = .pending
    var onEdit: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                if isSecure {
                    SecureField("", text: $text)
                        .placeholder(when: text.isEmpty) {
                            Text(title).foregroundColor(UIColor.lightGray)
                        }
                        .font(.systemFont(ofSize: 16))
                } else {
                    TextField("", text: $text, onEditingChanged: { changed in
                        if changed {
                            onEdit?()
                        }
                    })
                    .placeholder(when: text.isEmpty) {
                        Text(title).foregroundColor(UIColor.lightGray)
                    }
                    .font(.systemFont(ofSize: 16))
                }
            }
            .frame(height: 36)
            .font(.body)
            .foregroundColor(.CodeChallenge.white)
            Divider()
                .background(.CodeChallenge.white)
            Text(status.text)
                .accessibilityHint(status.text)
                .font(.body)
                .foregroundColor(.red)
                .lineLimit(1)
                .padding(.top, 4)
        }
        .accessibilityElement()
        .accessibilityLabel(title)
        .accessibilityValue(isSecure ? "" : text)
    }
}

extension LabelledField {
    enum Status: Equatable {
        case pending
        case valid
        case error(String?)

        var text: String {
            switch self {
            case .error(let message): return message ?? ""
            default: return ""
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
