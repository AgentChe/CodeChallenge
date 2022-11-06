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
                .font(.systemFont(ofSize: 14))
                .lineSpacing(10)
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.CodeChallenge.darkBlue))
        }
    }
}
