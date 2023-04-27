//
//  LessonTextView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 02/04/2023.
//

import Foundation
import SwiftUI

struct LessonTextView: View {
    let text: String

    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .font(.regular(size: 18))
            .padding(.horizontal, 20)
    }
}
