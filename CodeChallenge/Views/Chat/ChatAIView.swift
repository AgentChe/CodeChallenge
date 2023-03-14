//
//  ChatAI.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation
import SwiftUI

struct ChatAIView: View, ChatAIViewProps {
    @EnvironmentObject var store: Store
    @State private var message: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        DoodledView {
            VStack {
                HStack(spacing: 8) {
                    Spacer()
                        .frame(width: 4)
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                    }
                    Text("Let's chat ...")
                        .font(.h2)
                    Spacer()
                }
                ScrollViewReader { value in
                    ScrollView(.vertical) {
                        VStack() {
                            ForEach(Array(chatMessages.enumerated()), id: \.offset) { (offset, message) in
                                if let value = message.value {
                                    if value.role == .user {
                                        HStack {
                                            Spacer()
                                            MessageView(currentMessage: value)
                                        }
                                        .id(offset)
                                    } else {
                                        HStack {
                                            MessageView(currentMessage: value)

                                            Spacer()
                                        }
                                        .id(offset)
                                    }
                                } else {
                                    EmptyView()
                                }
                            }
                        }
                        .onChange(of: chatMessages.count) { messages in
                            withAnimation {
                                value.scrollTo(messages - 1)
                            }
                        }
                        .onReceive(keyboardPublisher) { height in
                            guard height != 0 else { return }
                            withAnimation {
                                value.scrollTo(chatMessages.count - 1)
                            }
                        }
                        .onAppear {
                            value.scrollTo(chatMessages.count - 1)
                        }
                    }
                }
                HStack {
                    TextField("type ur message", text: $message)
                    Button("Send") {
                        store.dispatch(SendMessageToAI(message: message))
                        message = ""
                    }
                    .foregroundColor(.CodeChallenge.blue1)
                }
                .padding(20)
                .background(.CodeChallenge.tabBar)
            }
        }
    }
}
