//
//  MessageView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation
import SwiftUI

struct MessageView : View {
    var currentMessage: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            Text(currentMessage.content)
                .padding(10)
                .foregroundColor(currentMessage.role == .user ? Color.white : Color.black)
                .background(currentMessage.role == .user ? Color(UIColor.CodeChallenge.blue1) : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                .cornerRadius(10)
        }.padding()
    }
}
