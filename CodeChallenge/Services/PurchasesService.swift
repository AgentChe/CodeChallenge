//
//  PurchasesService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/02/2023.
//

import Foundation
import Combine

protocol PurchasesServiceProtocol {
    func send(transactionId: String) -> AnyPublisher<Void, Error>
    func send(receipt: String, userId: Int) -> AnyPublisher<Void, Error>
}

struct PurchasesService: PurchasesServiceProtocol {
    let networkService: NetworkServiceProtocol

    func send(transactionId: String) -> AnyPublisher<Void, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/purchase/get/\(transactionId)", type: .get)
            .flatMap { networkService.send($0) }
            .eraseToAnyPublisher()
    }

    func send(receipt: String, userId: Int) -> AnyPublisher<Void, Error> {
        let params = ["receipt": receipt]
        return URLRequest
            .create(url: "\(Configuration.host)/purchase/verify/\(userId)", type: .post, params: params)
            .flatMap { networkService.send($0) }
            .eraseToAnyPublisher()
    }
}
