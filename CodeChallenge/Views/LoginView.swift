//
//  LoginView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import SwiftUI

struct LoginView: View {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
                .frame(height: 40)
            Text(mode == .login ? "Login" : "Sign up")
                .font(.largeTitle)
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
                    mode = mode == .login ? .signup : .login
                }
                .padding(.top, 30)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }

    private var loginOptionsView: some View {
        Group {
            HStack {
                Rectangle()
                    .background(Color.gray)
                    .frame(height: 2)
                Text("Login")
                Rectangle()
                    .background(Color.gray)
                    .frame(height: 2)
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
            TextField("Username", text: $userNameText)
                .autocapitalization(.none)
            SecureField("Password", text: $passwordText)
                .autocapitalization(.none)
            HStack {
                Spacer()
                Button("Forgot password") {

                }
            }
            Button("Login") {
                store.dispatch(Login(username: userNameText, password: passwordText))
            }
            .buttonStyle(PrimaryButton())
        }
    }

    private var signupView: some View {
        Group {
            TextField("Username", text: $signupUsernameText)
                .autocapitalization(.none)
            TextField("Email", text: $signupEmailText)
                .autocapitalization(.none)
            SecureField("Password", text: $signupPasswordText)
                .autocapitalization(.none)
            Button("Sign up") {
                store.dispatch(SignUp(email: signupEmailText, username: signupUsernameText, password: signupPasswordText))
            }
            .buttonStyle(PrimaryButton())
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
