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
    var screenMode: Mode
    let onChangeMode: (() -> Void)

    var body: some View {
        DoodledView {
            content
        }
        .onAppear {
            self.mode = screenMode
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
                .frame(height: 40)
            Text(mode == .login ? "Login" : "Sign up")
                .font(.systemFont(ofSize: 40, weight: .bold))
                .foregroundColor(.CodeChallenge.white)
            Spacer()
                .frame(height: 30)
            if mode == .login {
                loginView
            } else {
                signupView
            }

            Spacer()

            loginOptionsView

            HStack {
                Spacer()
                Button(mode == .login ? "Create Account" : "Have account") {
                    onChangeMode()
                }
                .padding(.top, 30)
                .foregroundColor(.CodeChallenge.blue1)
                Spacer()
            }

            Spacer()
                .frame(height: 20)
        }
        .padding(.horizontal, 25)
    }

    private var loginOptionsView: some View {
        Group {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 0.5)
                Text(mode == .login ? "Sign In with" : "Sign Up with")
                    .foregroundColor(.CodeChallenge.white)
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 0.5)
            }

            HStack {
                Spacer()
                ForEach(Range(0...4)) { _ in
                    Rectangle()
                        .frame(width: 50, height: 50)
                        .cornerRadius(25)
                }
                Spacer()
            }
        }
    }

    private var loginView: some View {
        Group {
            LabelledField(text: $userNameText, title: "Username")
                .autocapitalization(.none)
            LabelledField(text: $passwordText, title: "Password", isSecure: true)
                .autocapitalization(.none)
            HStack {
                Spacer()
                Button("Forgot password") {

                }
                .foregroundColor(UIColor.lightGray)
                .font(.systemFont(ofSize: 14))
            }
            Button("Login") {
                store.dispatch(Login(username: userNameText, password: passwordText))
            }
            .buttonStyle(PrimaryButton())
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
            .buttonStyle(PrimaryButton())
        }
    }
}
