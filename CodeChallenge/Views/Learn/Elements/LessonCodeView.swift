//
//  LessonCodeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 02/04/2023.
//

import Foundation
import SwiftUI

struct LessonCodeView: View {
    let code: String
    let pl: String

    var body: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            Text(code)
                .foregroundColor(.white)
                .padding(.vertical, 20)
            Spacer()
            Spacer()
                .frame(width: 20)
        }
        .background {
            Rectangle()
                .fill(Color(UIColor.CodeChallenge.darkBlue))
        }
    }
}
