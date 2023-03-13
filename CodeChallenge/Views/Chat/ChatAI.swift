//
//  ChatAI.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation
import SwiftUI

struct ChatAI: View {
    var body: some View {
        VStack {
            Text("We are supposed to have chat here ... but since chat is not developed yet, here's a cute pic of im ser Vahe in his office")
            Image("vahe")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
        }
    }
}
