//
//  CodeChallengeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation
import SwiftUI
import WebKit

struct CodeChallengeView: View, CodeChallengeViewProps {
    @EnvironmentObject var store: Store
    let codeChallenge: Challenge
    let onSeeSolution: (ChallengeDetail?) -> Void
    let onSuccess: (ChallengeDetail?) -> Void
    let onDismiss: () -> Void
    let onGoPremium: () -> Void
    let onOpenChat: (ChallengeDetail?, ChatMessagesMode) -> Void
    @State var selection: Int = 0
    @State var specialCharacter: String?
    @State private var displayCode: String?
    @State private var showsError: Bool = false
    @State private var showsResetProgressPopup = false
    @State private var resettedTemplate: String?
    @State private var bottomSheetShown = false
    @State private var keyboardHeight: CGFloat = 0
    let quickAccessCharBottomToCover: CGFloat = UIDevice.hasSmallScreen ? 10 : 17
    let quickAccessCharViewHeight: CGFloat = UIDevice.hasSmallScreen ? 65 : 95
    @State private var showPremiumPopup: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if !shouldShowPremiumPopup {
                    Spacer()
                        .frame(height: 10)
                    SegmentedControlView(
                        selection: $selection,
                        sections: ["Task", "Code", "Result"],
                        onValueChange: { selection in
                            self.selection = selection
                        })
                    .padding(.horizontal, 25)
                    .frame(height: 31)
                }

                switch selection {
                case 0:
                    if !isLoading, let details = details {
                        problemScreen(challengeDetails: details)
                    } else {
                        SkeletonCodeChallengeView()
                    }
                case 1:
                    codeScreen
                case 2:
                    resultScreen
                default: Text("")
                }
            }
            if showPremiumPopup {
                Rectangle()
                    .fill(Color.black)
                    .opacity(0.85)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showPremiumPopup = false
                        }
                    }
                premiumPopup
                    .transition(.move(edge: .bottom).animation(.easeInOut(duration: 0.3)))
                    .zIndex(3)
            }
        }
        .onAppear(perform: {
            store.dispatch(LoadChallengeDetails(id: codeChallenge.id))
            store.dispatch(LoadChallengeProgress(challengeId: codeChallenge.id))
            displayCode = removeTrailingNewLines(string: code.removingPercentEncoding ?? code)
        })
        .onChange(of: code, perform: { newValue in
            let decodedCode = newValue.removingPercentEncoding ?? newValue
            displayCode = removeTrailingNewLines(string: decodedCode)
        })
        .onChange(of: compilerTestCases) { newValue in
            guard gotCompileError == false, let _ = newValue else { return }
            selection = 2
            if let details = details, (testCases.filter { !$0.isFailed }.count == testCases.count), !testCases.isEmpty {
                if !celebratedChallenges.contains(details.id) {
                    set(celebratedChallenge: details)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onSuccess(details)
                    }
                }
            }
        }
        .onChange(of: selection, perform: { newValue in
            if newValue == 1 {
                store.dispatch(TrackAnalyticsEvent(event: .startedSolving(codeChallenge, programmingLanguage)))
            }
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(codeChallenge.name)
                        .foregroundColor(.white)
                        .font(.h3)
                    Spacer()

                    if selection == 1 && removeTrailingNewLines(string: template.removingPercentEncoding ?? template) != displayCode {
                        Image("reset")
                            .onTapGesture {
                                showsResetProgressPopup = true
                            }
                    } else {
                        EmptyView()
                    }
                }
            }
        }
        .background(Color.dark.edgesIgnoringSafeArea(.all))
        .onChange(of: output) { _ in
            keyboardHeight = 0
            UIApplication.shared.endEditing()

            if gotCompileError == true {
                withAnimation {
                    bottomSheetShown = true
                }
            }
        }
    }

    func problemScreen(challengeDetails: ChallengeDetail) -> some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Spacer()
                        .frame(height: 25)
                    Text(codeChallenge.name)
                        .font(.h3)
                    HtmlAttributedLabel(htmlAttributedString: challengeDetails.body.toAttributedString(), foregroundColor: .white)
                        .frame(width: .screenWidth - 40)

                    if let input = taskInput {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Input:")
                                .foregroundColor(.CodeChallenge.mediumBlue)
                                .font(.medium(size: 20))
                            Text(input)
                                .foregroundColor(.white)
                                .font(.h5)
                        }
                    }

                    if let output = taskOutput {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Output:")
                                .foregroundColor(.CodeChallenge.mediumBlue)
                                .font(.medium(size: 20))
                            Text(output)
                                .foregroundColor(.white)
                                .font(.h5)
                        }
                    }
                }
                .frame(width: .screenWidth - 40)
                .padding(.horizontal, 20)
            }
            Spacer()
            if details?.isPremium == true {
                HStack(spacing: 10) {
                    Button("Start solving", action: {
                        if shouldShowPremiumPopup {
                            withAnimation {
                                showPremiumPopup = true
                            }
                        } else {
                            selection = 1
                        }
                    })
                    .buttonStyle(PremiumGradientButton())
                    if store.state.maintenance?.aiEnabled == true {
                        aiButton
                            .modifier(PremiumGradientModifier())
                            .onTapGesture {
                                if shouldShowPremiumPopup {
                                    withAnimation {
                                        showPremiumPopup = true
                                    }
                                } else {
                                    onOpenChat(details, .provideSolution)
                                }
                            }
                    }
                }
                .padding(20)
            } else {
                HStack(spacing: 10) {
                    Button("Start solving") {
                        selection = 1
                    }
                    .buttonStyle(PrimaryButton())
                    if store.state.maintenance?.aiEnabled == true {
                        aiButton
                            .onTapGesture {
                                onOpenChat(details, .provideSolution)
                            }
                            .background {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(UIColor.CodeChallenge.blue1))
                            }
                    }
                }
                .padding(20)
            }

        }
        .foregroundColor(.CodeChallenge.white)
    }

    private var quickAccessCharBottomInset: CGFloat {
        keyboardHeight != 0 ? 0 : 100 - quickAccessCharBottomToCover - (UIApplication.shared.mainWindow?.safeAreaInsets.bottom ?? 0)
    }

    private var aiButton: some View {
        HStack {
            Spacer()
            Image("ai")
                .resizable()
                .frame(width: 36, height: 36)
            Text("Ask AI")
                .font(.button)
                .foregroundColor(.white)
                .frame(height: 56)
            Spacer()
        }
        .frame(width: .screenWidth/2 - 23)
    }

    var codeScreen: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    CodePlaygroundView(
                        specialCharacter: $specialCharacter,
                        code: $displayCode,
                        resettedTemplate: $resettedTemplate,
                        bottomInset: geometry.size.height - quickAccessCharViewHeight,
                        programmingLanguage: programmingLanguage,
                        aiGenerated: details?.aiGenerated, aiEnabled: store.state.maintenance?.aiEnabled == true) { code in
                            DispatchQueue.main.async {
                                displayCode = removeTrailingNewLines(string: code)
                            }
                        }
                    QuickAccessCharsView(challengeId: codeChallenge.id, onRun: {
                        showsError = true
                        store.dispatch(UpdateChallengeProgress(challenge: codeChallenge, solution: displayCode ?? "", compile: true, programmingLanguage: programmingLanguage, language: "en"))
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
                        if gotCompileError == true, store.state.maintenance?.aiEnabled == true {
                            Text("Ask AI why?")
                                .font(.button)
                                .foregroundColor(.CodeChallenge.white)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 16)
                                .onTapGesture {
                                    onOpenChat(details, .explain)
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
        //        }
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
                store.dispatch(UpdateChallengeProgress(challenge: codeChallenge, solution: template, compile: false, programmingLanguage: programmingLanguage, language: "en"))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    resettedTemplate = nil
                }
            }))
        })
        .onDisappear {
            keyboardHeight = 0
            bottomSheetShown = false
        }
    }

    var resultScreen: some View {
        CodeChallengeTestCasesView(testCases: testCases, showsSolution: details?.solutionCode.code != nil, onSeeSolution: {
            onSeeSolution(details)
        }) {
            selection = 1
        } onContinue: {
            onDismiss()
        }
    }

    private func removeTrailingNewLines(string: String) -> String {
        if string.last == "\n" {
            let newString = String(string.prefix(string.count - 1))
            return removeTrailingNewLines(string: newString)
        } else {
            return string
        }
    }

    private var premiumPopup: some View {
        VStack {
            Spacer()
            ZStack(alignment: .leading) {
                VStack(spacing: 12) {
                    Spacer()
                        .frame(height: 18)
                    Text("Challenge Locked")
                        .font(.h2)
                        .padding(.horizontal, 4)
                    Text("Go Premium to unlock the challenge")
                        .font(.smallText)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 15)
                    HStack {
                        Spacer()
                        Text("Start 14-day Free Trial")
                            .font(.button)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .modifier(PremiumGradientModifier(cornerRadius: 10, corners: [.bottomLeft, .bottomRight]))
                    .onTapGesture {
                        onGoPremium()
                    }
                }
                .foregroundColor(.white)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.CodeChallenge.background))
                }
            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .frame(width: .screenWidth)
    }
}

struct SkeletonCodeChallengeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Spacer()
                .frame(height: 25)
            Text("random title")
                .font(.systemFont(ofSize: 24, weight: .semibold))
            Text("a random description")
                .font(.systemFont(ofSize: 18, weight: .semibold))
                .foregroundColor(.CodeChallenge.blue1)
            Text("this text is a lot of details and its supposed to look big redacted. So I am just gonna continue this poem and think that im a poet")
                .font(.systemFont(ofSize: 18, weight: .semibold))
            Spacer()
        }
        .foregroundColor(.CodeChallenge.white)
        .padding(.horizontal, 20)
        .redacted(reason: .placeholder)
    }
}

fileprivate extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
