//
//  MessageView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/03/2023.
//

import Foundation
import SwiftUI
import Highlightr

struct MessageView : View {
    var currentMessage: ChatMessage
    @State private var displayMessages: [(isCode: Bool, ChatMessage)] = []

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            ForEach(Array(displayMessages.enumerated()), id: \.offset) { (_, element) in
                if element.0 {
                    HStack {
                        Spacer()
                        Text(element.1.content)
                            .frame(width: .screenWidth - 60)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(10)
                    .foregroundColor(Color.white)
                    .background(Color(.CodeChallenge.darkBlue))
                    .cornerRadius(10)
                } else {
                    HStack {
                        Spacer()
                        Text(element.1.content)
                            .padding(10)
                            .foregroundColor(Color.white)
                            .background(Color(UIColor.CodeChallenge.blue1))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.trailing, 10)
        .padding(.leading, 30)
        .onAppear {
                let codeChunks = currentMessage.content.replacingOccurrences(of: "\n\n", with: "\n")
                    .sliceMultipleTimes(from: ":\n```", to: "```\n")
                    .filter { !$0.isEmpty && $0 != "\n" }

                let texts = currentMessage.content.replacingOccurrences(of: "\n\n", with: "\n")
                    .components(separatedBy: "```")
                    .filter { !$0.isEmpty && $0 != "\n" }

                let messages = texts.map{ (isCode: codeChunks.contains($0), ChatMessage(role: .assistant, content: $0.trimmingCharacters(in: .whitespacesAndNewlines), timestamp: nil)) }

                displayMessages = messages
            }
    }
}

struct AssistantMessageView: View {
    var currentMessage: ChatMessage
    @State private var displayMessages: [(isCode: Bool, ChatMessage)] = []
    let animateChatMessages: Bool
    let showPromptView: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            VStack {
                Image("logo")
                    .resizable()
                    .frame(width: 40, height: 40)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(displayMessages.enumerated()), id: \.offset) { (_, element) in
                    if element.0 {
                        HStack {
                            Text(element.1.content)
                                .frame(width: .screenWidth - 100)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(10)
                        .foregroundColor(Color.white)
                        .background(Color(.CodeChallenge.darkBlue))
                        .cornerRadius(10)
                        .transition(.move(edge: .bottom))
                    } else {
                        Text(element.1.content)
                            .padding(10)
                            .foregroundColor(Color.black)
                            .background(Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                            .cornerRadius(10)
                        .transition(.move(edge: .bottom))
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .onAppear {
                let codeChunks = currentMessage.content.replacingOccurrences(of: "\n\n", with: "\n")
                    .sliceMultipleTimes(from: ":\n```", to: "```")
                    .filter { !$0.isEmpty && $0 != "\n" }

                let texts = currentMessage.content.replacingOccurrences(of: "\n\n", with: "\n")
                    .components(separatedBy: "```")
                    .filter { !$0.isEmpty && $0 != "\n" }

                let messages = texts.map{ (isCode: codeChunks.contains($0), ChatMessage(role: .assistant, content: $0.trimmingCharacters(in: .whitespacesAndNewlines), timestamp: nil)) }

                if animateChatMessages {
                    for index in 0..<messages.count {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.5 * Double(index))) {
                            withAnimation(.spring()) {
                                self.displayMessages.append(messages[index])
                            }
                        }
                    }
                } else {
                    self.displayMessages = messages
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.5 * Double(messages.count))) {
                    showPromptView()
                }
            }
    }

//    private func getCodeAttributedString(code: String) -> NSMutableAttributedString? {
//        let highlightr = Highlightr()
//        highlightr?.setTheme(to: "atom-one-dark-reasonable")
//        // You can omit the second parameter to use automatic language detection.
//        guard let highlightedCode = highlightr?.highlight(code, as: "python") else { return nil }
//        return NSMutableAttributedString(attributedString: highlightedCode)
//    }
}

extension String {
    func sliceMultipleTimes(from: String, to: String) -> [String] {
        components(separatedBy: from).dropFirst().compactMap { sub in
            (sub.range(of: to)?.lowerBound).flatMap { endRange in
                String(sub[sub.startIndex ..< endRange])
            }
        }
    }
}

struct LoadingAssistantMessage: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            VStack {
                Image("logo")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .aspectRatio(contentMode: .fill)
                Spacer()
            }
            VStack(alignment: .leading) {
                Text("some random a little bigger text to show beatufully in loading mode, let's make some art, shall we?")
                    .padding(10)
                    .foregroundColor(Color.white)
                    .background(.CodeChallenge.darkBlue)
                    .cornerRadius(10)
                .transition(.move(edge: .bottom))
                .frame(width: .screenWidth - 100)
            }
            .redacted(reason: .placeholder)
//            .animatePlaceholder()
        }
        .padding(.horizontal, 10)
    }
}
