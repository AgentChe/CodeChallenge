//
//  LoginView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import SwiftUI

struct LoginView: View, LoginViewProps {
    enum Mode {
        case login
        case signup
    }
    @EnvironmentObject var store: Store
    @State var userNameText: String = ""
    @State var passwordText: String = ""
    @State var signupUsernameText: String = ""
    @State var signupEmailText: String = ""
    @State var signupPasswordText: String = ""
    @State var mode = Mode.login
    @State var showAlert = false
    @State var displayErrorMessage: String?
    @State var showMergeAlert = false
    var screenMode: Mode
    let onChangeMode: (() -> Void)

    var body: some View {
        DoodledView {
            VStack(spacing: 4) {
                ScrollView {
                    content
                }

                Spacer()

                HStack {
                    Spacer()
                    Button(mode == .login ? "Create Account" : "Have account") {
                        onChangeMode()
                    }
                    .padding(.top, 30)
                    .foregroundColor(.CodeChallenge.blue1)
                    Spacer()
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Something went wrong"),
                        message: Text(displayErrorMessage ?? "Please try again!"),
                        dismissButton: .default(Text("OK"), action: {
                            store.dispatch(Action.loadUser(.pending))
                        })
                    )
                }

                Spacer()
                    .frame(height: 10)
            }
        }
        .onAppear {
            self.mode = screenMode
            if self.mode == .login {
                store.dispatch(TrackAnalyticsEvent(event: .loginSelected))
            } else {
                store.dispatch(TrackAnalyticsEvent(event: .signUpSelected))
            }
        }
        .onReceive(errorPublisher) { errorMessage in
            guard !showAlert else { return }
            displayErrorMessage = errorMessage
            showAlert = true
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
                .frame(height: 15)
            Text(mode == .login ? "Login" : "Sign up")
                .font(.pageNameH1)
                .foregroundColor(.CodeChallenge.white)
            Spacer()
                .frame(height: 10)
            if mode == .login {
                loginView
            } else {
                signupView
            }
        }
        .padding(.horizontal, 25)
    }

    private var loginView: some View {
        Group {
            LabelledField(text: $userNameText, title: "Username")
                .autocapitalization(.none)
            LabelledField(text: $passwordText, title: "Password", isSecure: true)
                .autocapitalization(.none)
            Button("Login") {
                showMergeAlert = true
            }
            .buttonStyle(PrimaryButton(status: buttonStatus))
            .alert(isPresented: $showMergeAlert) {
                Alert(
                    title: Text("Do you want to merge the progress?"),
                    message: Text(displayErrorMessage ?? "You can not undo this action"),
                    primaryButton: .destructive(Text("Yes"), action: {
                        store.dispatch(Login(username: userNameText, password: passwordText, merge: true))
                    }),
                    secondaryButton: .default(Text("No"), action: {
                        store.dispatch(Login(username: userNameText, password: passwordText, merge: false))
                    })
                )
            }
        }
    }

    private var signupView: some View {
        Group {
            LabelledField(text: $signupUsernameText, title: "Username")
                .autocapitalization(.none)
            LabelledField(text: $signupEmailText, title: "Email")
                .autocapitalization(.none)
            LabelledField(text: $signupPasswordText, title: "Password", isSecure: true)
                .autocapitalization(.none)
            Button("Sign up") {
                store.dispatch(SignUp(email: signupEmailText, username: signupUsernameText, password: signupPasswordText))
            }
            .buttonStyle(PrimaryButton(status: buttonStatus))
        }
    }
}
