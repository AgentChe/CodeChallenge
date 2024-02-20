//
//  CodeChallengeContentsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 20/03/2023.
//

import Foundation
import SwiftUI

struct CodeChallengeContentsView: View, CodeChallengeContentsViewProps {
    @EnvironmentObject var store: Store

    let codeChallenge: Challenge
    let onSeeSolution: (ChallengeDetail?) -> Void
    let onSuccess: (ChallengeDetail?) -> Void
    let onDismiss: () -> Void
    let onGoPremium: () -> Void
    let onOpenChat: (ChatMessagesMode) -> Void

    @State private var displayCode: String?
    @State private var selection: Int = 0
    @State private var showsResetProgressPopup: Bool = false
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

                if let details = details {
                    views(details: details)
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
            store.dispatch(LoadChallengeProgress(challengeId: codeChallenge.id, onComplete: nil))
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(codeChallenge.name)
                        .foregroundColor(.white)
                        .font(.h3)
                    Spacer()

                    if selection == 1 && template.removingPercentEncoding != displayCode {
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
        .onAppear(perform: {
            displayCode = code.removingPercentEncoding ?? code
        })
        .onChange(of: code, perform: { newValue in
            displayCode = newValue.removingPercentEncoding ?? newValue
        })
        .onChange(of: compilerTestCases) { newValue in
            if (testCases.filter { !$0.isFailed }.count == testCases.count), !testCases.isEmpty {
                selection = 2
                if !celebratedChallenges.contains(details?.id ?? 0), let details = details {
                    set(celebratedChallenge: details)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onSuccess(details)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func views(details: ChallengeDetail) -> some View {
        switch selection {
        case 0:
            if !isLoading {
                CodeChallengeTaskView(
                    details: details,
                    onStartSolving: {
                    selection = 1
                },
                    onPremiumPopupShow: {
                        withAnimation {
                            showPremiumPopup = true
                        }
                },
                    onGoPremium: onGoPremium, onOpenChat: onOpenChat)
            } else {
                SkeletonCodeChallengeView()
            }
        case 1:
            CodeChallengePlaygroundView(
                details: details,
                displayCode: $displayCode,
                showsResetProgressPopup: $showsResetProgressPopup,
                onOpenChat: onOpenChat, onRun: { (code, compile) in
                store.dispatch(UpdateChallengeProgress(
                    challengeId: codeChallenge.id,
                    solution: code,
                    compile: compile,
                    programmingLanguage: programmingLanguage,
                    language: "en"
                ))
            })
        case 2:
            CodeChallengeTestCasesView(details: details, onSeeSolution: {
                onSeeSolution(details)
            }) {
                selection = 1
            } onContinue: {
                onDismiss()
            }
        default: EmptyView()
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
