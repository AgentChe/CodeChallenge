//
//  NoteView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 23/10/2022.
//

import Foundation
import SwiftUI

struct NoteView: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image("note_mark")
            Text(text)
                .foregroundColor(.white)
                .font(.regular(size: 14))
                .lineSpacing(10)
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.CodeChallenge.darkBlue))
        }
    }
}

struct PremiumNoteView: View {
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image("premium_note_mark")
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.h4)
                    .lineSpacing(10)
                Text(text)
                    .foregroundColor(.lightGray)
                    .font(.bodyText)
                    .lineSpacing(10)
            }
            .padding(.vertical, 5)
            Spacer()
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor.CodeChallenge.dustyBlue), lineWidth: 1)
        }
    }
}
