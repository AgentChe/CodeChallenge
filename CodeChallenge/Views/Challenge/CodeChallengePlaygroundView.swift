//
//  CodeChallengePlaygroundView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 20/03/2023.
//

import Foundation
import SwiftUI

struct CodeChallengePlaygroundView: View {
    @EnvironmentObject var store: Store
    let details: ChallengeDetail
    @Binding var displayCode: String?
    @Binding var showsResetProgressPopup: Bool
    let onOpenChat: ((ChatMessagesMode) -> Void)?
    let onRun: (String, Bool) -> Void
    let onSuccessfulRun: () -> Void

    @State var specialCharacter: String?
    @State private var showsError: Bool = false
    @State private var resettedTemplate: String?
    @State private var bottomSheetShown = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var showPremiumPopup: Bool = false
    private let quickAccessCharBottomToCover: CGFloat = UIDevice.hasSmallScreen ? 10 : 17
    private let quickAccessCharViewHeight: CGFloat = UIDevice.hasSmallScreen ? 65 : 95

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    CodePlaygroundView(
                        specialCharacter: $specialCharacter,
                        code: $displayCode,
                        resettedTemplate: $resettedTemplate,
                        bottomInset: geometry.size.height - quickAccessCharViewHeight,
                        programmingLanguage: programmingLanguage,
                        aiGenerated: details.aiGenerated, aiEnabled: store.state.maintenance?.aiEnabled == true) { code in
                            DispatchQueue.main.async {
                                displayCode = removeTrailingNewLines(string: code)
                            }
                        }
                    QuickAccessCharsView(challengeId: details.id, onRun: {
                        showsError = true
                        guard let displayCode = displayCode else { return }
                        onRun(displayCode, true)
                    }) { char in
                        specialCharacter = char
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            self.specialCharacter = nil
                        }
                    }
                }
            }
            .padding(.bottom, quickAccessCharBottomInset)
            BottomSheetView(
                isOpen: self.$bottomSheetShown,
                maxHeight: 300
            ) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(gotCompileError != nil ?
                             (gotCompileError == true ? "Error!" : "Compiled Successfully!") :
                                "Output")
                        .foregroundColor(gotCompileError != nil ?
                                         (gotCompileError == true ? .red : .green) :
                                .CodeChallenge.blue1)
                        .font(.h3)
                        Spacer()
                        if gotCompileError == true, store.state.maintenance?.aiEnabled == true,
                            let onOpenChat = onOpenChat {
                            Text("Explain Mistake")
                                .font(.button)
                                .foregroundColor(.CodeChallenge.white)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 16)
                                .onTapGesture {
                                    onOpenChat(.explain(latestCompiledCode ?? "", details))
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(UIColor.CodeChallenge.blue1))
                                }
                        }
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.CodeChallenge.dark))
                        ScrollView {
                            HStack {
                                Text(output)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 12)
                                    .font(UIFont.monospacedSystemFont(ofSize: 14, weight: .regular))
                                Spacer()
                            }
                        }
                        .frame(height: 180)
                    }
                    .frame(height: 200)
                }
                .padding(.horizontal, UIDevice.hasSmallScreen ? 10 : 24)
                .background(.CodeChallenge.background)
            }.edgesIgnoringSafeArea(.all)
        }
        .onReceive(keyboardPublisher) { value in
            keyboardHeight = value
            if value > 0 {
                withAnimation {
                    bottomSheetShown = false
                }
            }
        }
        .alert(isPresented: $showsResetProgressPopup, content: {
            Alert(title: Text("Are you sure you want to reset the progress?"),
                  message: Text("You won't be able to recover the progress on approve"),
                  primaryButton: .default(Text("No")),
                  secondaryButton: .destructive(Text("Yes"), action: {
                resettedTemplate = template
                onRun(template, false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    resettedTemplate = nil
                }
            }))
        })
        .onDisappear {
            keyboardHeight = 0
            bottomSheetShown = false
        }
        .onChange(of: output) { _ in
            keyboardHeight = 0
            UIApplication.shared.endEditing()

            if gotCompileError == true {
                withAnimation {
                    bottomSheetShown = true
                }
            } else {
                onSuccessfulRun()
            }
        }
    }

    private var quickAccessCharBottomInset: CGFloat {
        keyboardHeight != 0 ? 0 : 100 - quickAccessCharBottomToCover - (UIApplication.shared.mainWindow?.safeAreaInsets.bottom ?? 0)
    }

    private func removeTrailingNewLines(string: String) -> String {
        if string.last == "\n" {
            let newString = String(string.prefix(string.count - 1))
            return removeTrailingNewLines(string: newString)
        } else {
            return string
        }
    }
}

extension CodeChallengePlaygroundView {
    var template: String {
        return details.body.template
    }

    var programmingLanguage: ProgrammingLanguage {
        details.codehubProgrammingLanguage
    }

    var output: String {
        return store.state.challengeResults[details.id]?.value?.code.output.removingPercentEncoding ?? ""
    }

    var gotCompileError: Bool? {
        guard let statusCode = store.state.challengeResults[details.id]?.value?.code.statusCode else { return nil }
        return statusCode == 1
    }

    var latestCompiledCode: String? {
        store.state.challengeProgresses[details.id]?.value?.solution?.python.removingPercentEncoding ?? ""
    }
}

fileprivate extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
