//
//  ChallengeFriendCodeChallengeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 21/03/2023.
//

import Foundation
import SwiftUI

struct ChallengeFriendCodeChallengeView: View, ChallengeFriendCodeChallengeViewProps {
    @EnvironmentObject var store: Store

    let codeChallengeId: Int
    let onContinue: (Bool) -> Void

    @State private var displayCode: String?
    @State private var selection: Int = 0
    @State private var showsResetProgressPopup: Bool = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    @State private var countdown = 10
    @State private var popupText: String? = nil

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
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

                if let details = details {
                    views(details: details)
                }
            }

            if let _ = popupText {
                Rectangle()
                    .fill(Color.black)
                    .opacity(0.85)
                    .edgesIgnoringSafeArea(.all)
                resultPopup
                    .transition(.move(edge: .bottom).animation(.easeInOut(duration: 0.3)))
                    .zIndex(3)
            }
        }
        .onReceive(timer, perform: { _ in
            if countdown == 0 {
                timer.upstream.connect().cancel()
                withAnimation {
                    popupText = "failed"
                }
            } else {
                countdown = countdown - 1
            }
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("Time remaining: \(secondsToMinutesSeconds(countdown).0):\(secondsToMinutesSeconds(countdown).1)")
                        .foregroundColor(.white)
                        .font(.h3)
                    Spacer()

                    if selection == 1 && template != displayCode, popupText == nil {
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
        .navigationBarBackButtonHidden(true)
        .onChange(of: compilerTestCases) { newValue in
            if (testCases.filter { !$0.isFailed }.count == testCases.count), !testCases.isEmpty {
                selection = 2
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    timer.upstream.connect().cancel()
                    withAnimation {
                        popupText = "Success"
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
                    onPremiumPopupShow: nil,
                    onGoPremium: nil, onOpenChat: nil)
            } else {
                SkeletonCodeChallengeView()
            }
        case 1:
            CodeChallengePlaygroundView(
                details: details,
                displayCode: $displayCode,
                showsResetProgressPopup: $showsResetProgressPopup,
                onOpenChat: nil, onRun: { (code, compile) in
                store.dispatch(UpdateChallengeProgress(
                    challengeId: codeChallengeId,
                    solution: code,
                    compile: compile,
                    programmingLanguage: programmingLanguage,
                    language: "en"
                ))
            }, onSuccessfulRun: {
                selection = 2
            })
        case 2:
            CodeChallengeTestCasesView(details: details, onSeeSolution: nil) {
                selection = 1
            } onContinue: {
                onContinue(false)
            }
        default: EmptyView()
        }
    }

    private func secondsToMinutesSeconds(_ seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    private var resultPopup: some View {
        VStack {
            Spacer()
            ZStack(alignment: .leading) {
                VStack(spacing: 12) {
                    Spacer()
                        .frame(height: 18)
                    Text(popupText ?? "")
                        .font(.h2)
                        .padding(.horizontal, 4)
                    Text("some random description")
                        .font(.smallText)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 15)
                    Text("Continue")
                        .font(.button)
                        .padding(.vertical, 12)
                        .frame(width: .screenWidth - 40)
                    .background {
                        RoundedCornersShape(corners: [.bottomLeft, .bottomRight],
                                            radius: 10)
                        .fill(Color(UIColor.CodeChallenge.blue1))
                    }
                    .onTapGesture {
                        onContinue(popupText == "Success")
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
