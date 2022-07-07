//
//  AccountService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 08/07/2022.
//

import Foundation
import Combine
import UIKit

protocol AccountServiceProtocol {
    func loadAccount() -> AnyPublisher<Account, Error>
}

struct AccountService: AccountServiceProtocol {
    let networkService: NetworkServiceProtocol

    func loadAccount() -> AnyPublisher<Account, Error> {
        return URLRequest
            .create(url: "https://run.mocky.io/v3/ba0026b4-24bf-4200-b999-65d9bb69677a", type: .get)
            .flatMap { networkService.load($0, decoding: Account.self, with: JSONDecoder()) }
            .eraseToAnyPublisher()
    }
}
