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
    let mode: ChatMessagesMode
    @State private var showPromptViewIfSatisfied = false
    @State private var chatMessagesExisted = false

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
                    Text(mode.title)
                        .font(.h2)
                    Spacer()
                }
                .padding(.vertical, 12)
                ScrollViewReader { value in
                    ScrollView(.vertical) {
                        chatMessagesView
                        .onAppear {
                            chatMessagesExisted = !chatMessages.isEmpty
                            if chatMessages.count % 2 == 0 && !chatMessages.isEmpty {
                                showPromptViewIfSatisfied = true
                            }
                            withAnimation {
                                value.scrollTo(chatMessages.count - 1)
                            }
                        }
                        .onChange(of: chatMessages.count) { _ in
                            withAnimation {
                                value.scrollTo(chatMessages.count - 1)
                            }
                        }
                        .onReceive(keyboardPublisher) { _ in
                            withAnimation {
                                value.scrollTo(chatMessages.count - 1)
                            }
                        }
                    }
                }
                if mode.showInput {
                    inputView
                }
            }
            .onAppear {
                if chatMessages.isEmpty {
                    store.dispatch(SendMessageToAI(message: mode.startMessage, mode: mode))
                } else {
                    switch mode {
                    case .explain where !chatMessages.contains { $0.value?.content == mode.startMessage }:
                        store.dispatch(SendMessageToAI(message: mode.startMessage, mode: mode))
                    default: return
                    }
                }
            }
        }
    }

    private var chatMessagesView: some View {
        VStack(spacing: 26) {
            ForEach(Array(chatMessages.enumerated()), id: \.offset) { (offset, message) in
                if offset == 0 {
                    EmptyView()
                } else if let value = message.value {
                    if value.role == .user {
                        MessageView(currentMessage: value)
                        .id(offset)
                    } else {
                        VStack(spacing: 20) {
                            AssistantMessageView(currentMessage: value, animateChatMessages: !chatMessagesExisted, showPromptView: {
                                showPromptViewIfSatisfied = true
                            })
                            if !mode.answerPrompts.isEmpty, chatMessages.count % 2 == 0 && offset == chatMessages.count - 1, showPromptViewIfSatisfied {
                                promptView
                            }
                        }
                        .id(offset)
                    }
                } else {
                    EmptyView()
                }
            }
            if let error = assistantMessageError {
                AssistantMessageError(error: error)
            } else if assistantMessageIsLoading {
                LoadingAssistantMessage()
            }
        }
    }

    var inputView: some View {
        HStack {
            TextField("type ...", text: $message)
                .foregroundColor(.white)
                .clipShape(Rectangle())
            Button("Send") {
                if !message.isEmpty {
                    store.dispatch(SendMessageToAI(message: message, mode: mode))
                }
                message = ""
            }
            .foregroundColor(.CodeChallenge.blue1)
        }
        .padding(20)
        .background {
            Rectangle()
                .fill(Color(UIColor.CodeChallenge.darkBlue))
        }
    }

    var promptView: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                ForEach(mode.answerPrompts, id: \.self) { prompt in
                    Button(action: {
                        if dismissView(on: prompt) { presentationMode.wrappedValue.dismiss() } else {
                            showPromptViewIfSatisfied = false
                            store.dispatch(SendMessageToAI(message: prompt, mode: mode))
                        }
                    }, label: {
                        Text(prompt)
                            .frame(height: 40)
                            .padding(.horizontal, 12)
                            .foregroundColor(.CodeChallenge.blue1)
                            .font(.button)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(UIColor.CodeChallenge.blue1), lineWidth: 1.5)
                            }
                    })
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
