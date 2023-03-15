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
        HStack(alignment: .bottom, spacing: 15) {
            VStack(alignment: .trailing) {
                ForEach(Array(displayMessages.enumerated()), id: \.offset) { (_, element) in
                    if element.0 {
                        HStack {
                            Spacer()
                            Text(element.1.content)
                        }
                        .padding(10)
                        .foregroundColor(Color.white)
                        .background(Color(.CodeChallenge.darkBlue))
                        .cornerRadius(10)
                        .frame(width: .screenWidth - 20)
                    } else {
                        HStack {
                            Spacer()
                            Text(element.1.content)
                        }
                            .padding(10)
                            .foregroundColor(Color.white)
                            .background(Color(UIColor.CodeChallenge.blue1))
                            .cornerRadius(10)
                            .frame(width: .screenWidth - 20)
                    }
                }
            }
        }.padding()
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
    let showPromptView: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if currentMessage.role == .assistant {
                VStack {
                    Image("logo")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .aspectRatio(contentMode: .fill)
                    Spacer()
                }
            }
            VStack(alignment: .leading) {
                ForEach(Array(displayMessages.enumerated()), id: \.offset) { (_, element) in
                    if element.0 {
                        //                        if let attributedString = getCodeAttributedString(code: element.1.content) {
                        //                            HtmlAttributedLabel(htmlAttributedString: attributedString, foregroundColor: nil, inset: 115)
                        ////                                .padding(10)
                        ////                                .background(Color(.CodeChallenge.darkBlue))
                        ////                                .cornerRadius(10)
                        //                                .frame(width: .screenWidth - 80)
                        //                            //                                .transition(.move(edge: .bottom))
                        //                        }

                        HStack {
                            Text(element.1.content)
                            Spacer()
                        }
                        .padding(10)
                        .foregroundColor(Color.white)
                        .background(Color(.CodeChallenge.darkBlue))
                        .cornerRadius(10)
                        .transition(.move(edge: .bottom))
                        .frame(width: .screenWidth - 80)
                    } else {
                        HStack {
                            Text(element.1.content)
                            Spacer()
                        }
                        .padding(10)
                        .foregroundColor(Color.black)
                        .background(Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                        .cornerRadius(10)
                        .transition(.move(edge: .bottom))
                        .frame(width: .screenWidth - 80)
                    }
                }
            }

        }.padding()
            .onAppear {
                let codeChunks = currentMessage.content.replacingOccurrences(of: "\n\n", with: "\n")
                    .sliceMultipleTimes(from: ":\n```", to: "```")
                    .filter { !$0.isEmpty && $0 != "\n" }

                let texts = currentMessage.content.replacingOccurrences(of: "\n\n", with: "\n")
                    .components(separatedBy: "```")
                    .filter { !$0.isEmpty && $0 != "\n" }

                let messages = texts.map{ (isCode: codeChunks.contains($0), ChatMessage(role: .assistant, content: $0.trimmingCharacters(in: .whitespacesAndNewlines), timestamp: nil)) }

                for index in 0..<messages.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.5 * Double(index))) {
                        withAnimation(.spring()) {
                            self.displayMessages.append(messages[index])
                        }
                    }
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
