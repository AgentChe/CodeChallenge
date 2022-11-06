//
//  LoginViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import Combine

protocol LoginViewProps {
    var store: Store { get }
    var screenMode: LoginView.Mode { get set }
    var userNameText: String { get set }
    var passwordText: String { get set }
    var signupUsernameText: String { get set }
    var signupEmailText: String { get set }
    var signupPasswordText: String { get set }
}

extension LoginViewProps {
    var userIsLoading: Bool {
        return store.state.account.isLoading
    }

    var buttonStatus: PrimaryButton.Status {
        if userIsLoading {
            return .loading
        }
        if screenMode == .login {
            return (!userNameText.isEmpty && !passwordText.isEmpty ? .enabled : .disabled)
        } else if screenMode == .signup {
            return (!signupUsernameText.isEmpty && !signupEmailText.isEmpty && !signupPasswordText.isEmpty ? .enabled : .disabled)
        }
        return .disabled
    }

    var errorPublisher: AnyPublisher<Bool, Never> {
        store.$state
            .map { $0.user }
            .removeDuplicates()
            .map { $0.error != nil }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
