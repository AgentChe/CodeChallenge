//
//  RequestAdditions.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import Combine

extension URLRequest {
    init?(
        url: String,
        queryItems: [URLQueryItem] = [],
        type: RequestType = .get,
        params: Any? = nil,
        bodyType: BodyType = .json,
        headers: [String: String] = RequestType.jsonRequestHeaders
    ) {
        var components = URLComponents(string: url)
        let items = [components?.queryItems, queryItems].compactMap { $0 }.flatMap { $0 }
        if !items.isEmpty {
            components?.queryItems = items
        }
        guard let resultURL = components?.url else { return nil }
        self.init(url: resultURL)
        httpMethod = type.rawValue.uppercased()
        headers.forEach { self.setValue($0.1, forHTTPHeaderField: $0.0) }

        guard let params = params else { return }
        switch bodyType {
        case .urlQuery:
            let dictParams = params as? [String: String]
            let items = dictParams?.map { URLQueryItem(name: $0.0, value: $0.1) }
            var components = URLComponents(url: resultURL, resolvingAgainstBaseURL: false)
            components?.queryItems = items
            let data = components?.query?.data(using: .utf8)
            httpBody = data
            setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        case .json:
            let data = try? JSONSerialization.data(withJSONObject: params, options: .init())
            httpBody = data
        }
    }

    static func create(
        url: String,
        queryItems: [URLQueryItem] = [],
        type: RequestType = .get,
        params: Any? = nil,
        bodyType: BodyType = .json,
        headers: [String: String] = RequestType.jsonRequestHeaders
    ) -> AnyPublisher<URLRequest, Error> {
        Future<URLRequest, Error> { promise in
            guard
                let request = URLRequest(
                    url: url,
                    queryItems: queryItems,
                    type: type,
                    params: params,
                    bodyType: bodyType,
                    headers: headers
                )
            else {
                promise(.failure(NetworkError.invalidURL))
                return
            }
            promise(.success(request))
        }
        .share()
        .eraseToAnyPublisher()
    }
}

extension URLRequest {
    enum RequestType: String {
        case get, post, put, patch, delete

        static var jsonRequestHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    enum BodyType {
        case urlQuery, json
    }
}
