//
//  PracticeLoadingView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 27/11/2022.
//

import Foundation
import SwiftUI

struct PracticeLoadingView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.CodeChallenge.dark))
            Image("premium")
            VStack() {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Spacer()
                    .frame(height: 80)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
