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
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 7)
            HStack(spacing: 4) {
                Spacer()
                    .frame(width: 10)
                Text(store.state.programmingLanguage.rawValue.capitalized)
                    .foregroundColor(.white)
                    .font(.h5)
                Image("language_picker_down_arrow")
                Spacer()
                    .frame(width: 10)
            }
            Spacer()
                .frame(height: 7)
        }
        .frame(height: 32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.CodeChallenge.dustyBlue), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.CodeChallenge.dark)))
            )
    }
}
