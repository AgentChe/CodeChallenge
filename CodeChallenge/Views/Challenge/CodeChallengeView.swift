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
                    CodeChallengePickerView(
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
                    HtmlAttributedLabel(htmlAttributedString: challengeDetails.body.toAttributedString())
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
            }
            Spacer()
            if details?.isPremium == true {
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
                .padding(.bottom, 20)
            } else {
                Button("Start solving") {
                    selection = 1
                }
                .buttonStyle(PrimaryButton())
                .padding(.bottom, 20)
            }

        }
        .foregroundColor(.CodeChallenge.white)
        .padding(.horizontal, 20)
    }

    private var quickAccessCharBottomInset: CGFloat {
        keyboardHeight != 0 ? 0 : 100 - quickAccessCharBottomToCover - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
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
                        programmingLanguage: programmingLanguage) { code in
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
                            Spacer()
                            Text(gotCompileError != nil ?
                                 (gotCompileError == true ? "Compilation Error!" : "Compiled Successfully!") :
                                    "Output")
                                .foregroundColor(gotCompileError != nil ?
                                                 (gotCompileError == true ? .red : .green) :
                                        .CodeChallenge.blue1)
                                .font(.h3)
                            Spacer()
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

struct CodeChallengePickerView: UIViewRepresentable {
    @Binding var selection: Int
    let sections: [String]
    let onValueChange: (Int) -> Void

    func makeUIView(context: Context) -> some UIView {
        let view = CodeChallengePickerUIView(
            sections: sections, onValueChange: onValueChange
        )
        view.heightAnchor.constraint(equalToConstant: 31).isActive = true
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 50).isActive = true
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        (uiView as? CodeChallengePickerUIView)?.segmentedControl.selectedSegmentIndex = selection
    }
}

fileprivate class CodeChallengePickerUIView: UIView {
    let sections: [String]
    let onValueChange: (Int) -> Void
    var segmentedControl: UISegmentedControl!

    override init(frame: CGRect) {
        self.sections = []
        self.onValueChange = { _ in }
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        self.sections = []
        self.onValueChange = { _ in }
        super.init(coder: coder)
    }

    init(sections: [String],
         onValueChange: @escaping (Int) -> Void) {
        self.sections = sections
        self.onValueChange = onValueChange
        super.init(frame: .zero)
        commonInit()
    }

    func commonInit() {
        segmentedControl = UISegmentedControl(items: sections)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = UIColor.CodeChallenge.blue1
        segmentedControl.backgroundColor = UIColor.CodeChallenge.dark
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)

        segmentedControl.addTarget(self, action: #selector(changedValue(segmentedControl:)), for: .valueChanged)
        self.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: self.topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

    @objc private func changedValue(segmentedControl: UISegmentedControl) {
        onValueChange(segmentedControl.selectedSegmentIndex)
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
