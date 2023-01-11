//
//  LanguagePicker.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 25/12/2022.
//

import Foundation
import SwiftUI

struct LanguagePickerIconView: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        HStack(spacing: 4) {
            Text(store.state.programmingLanguage.rawValue.capitalized)
                .foregroundColor(.white)
                .font(.h5)
            Image("language_picker_down_arrow")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .frame(height: 32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.CodeChallenge.dustyBlue), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.CodeChallenge.dark)))
            )
    }
}
