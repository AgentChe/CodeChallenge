//
//  NetworkService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func load<T: Decodable>(
        _ request: URLRequest,
        decoding _: T.Type,
        with decoder: JSONDecoder
    ) -> AnyPublisher<T, Error>

    func send(_ request: URLRequest) -> AnyPublisher<Void, Error>
    func resolveRedirections(_ request: URLRequest) -> AnyPublisher<URL?, Error>
}

enum NetworkError: LocalizedError {
    typealias StatusCode = Int
    case invalidURL
    case generic(Error)
    case invalidResponse
    case internalInconsistency
    case decoding(StatusCode, Error)
    case api(StatusCode, Data)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .generic(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "Invalid Response"
        case .api: //TODO: map data to error
            return "Unknown error"
        case .internalInconsistency:
            return "Internal inconsistency"
        case .decoding(_, let error):
            return error.localizedDescription
        }
    }
}

final class NetworkService: NetworkServiceProtocol {
    var session: URLSession

    init(
        session: URLSession = URLSession.shared
    ) {
         self.session = session
    }

    func load<T: Decodable>(
        _ request: URLRequest,
        decoding _: T.Type,
        with decoder: JSONDecoder = .init()
    ) -> AnyPublisher<T, Error> {
        return session
            .dataTask(for: request)
            .mapResponse()
            .tryMap {
                do {
                    let decoded = try decoder.decode(T.self, from: $0.0)
                    return decoded
                } catch {
                    throw NetworkError.decoding($0.1.statusCode, error)
                }
            }
            .receive(on: DispatchQueue.main)
            .share()
            .eraseToAnyPublisher()
    }

    func send(_ request: URLRequest) -> AnyPublisher<Void, Error> {
        return session
            .dataTask(for: request)
            .mapResponse()
            .map { _ in () }
            .receive(on: DispatchQueue.main)
            .share()
            .eraseToAnyPublisher()
    }

    func resolveRedirections(_ request: URLRequest) -> AnyPublisher<URL?, Error> {
        return session
            .dataTaskPublisher(for: request)
            .mapResponse()
            .map { (_, response) in
                response.url
            }
            .receive(on: DispatchQueue.main)
            .share()
            .eraseToAnyPublisher()
    }
}

fileprivate extension URLSession {
    func dataTask(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return dataTaskPublisher(for: request)
#if DEBUG && false
            .handleEvents(
                receiveOutput: { (_: Data, response: URLResponse) in
                    let httpMethod = request.httpMethod?.uppercased() ?? ""
                    let httpResponse = response as? HTTPURLResponse
                    let url = httpResponse?.url?.absoluteString ?? "--"
                    debugPrint("\(httpMethod) \(url) \(httpResponse?.statusCode ?? 0)")
                },
                receiveCompletion: { result in
                    if case let .failure(error) = result {
                        let httpMethod = request.httpMethod?.uppercased() ?? ""
                        let url = request.url?.absoluteString ?? "--"
                        debugPrint("\(httpMethod) \(url) \(error)")
                    }
                }
            )
#endif
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == (data: Data, response: URLResponse) {
    func mapResponse() -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        tryMap { (data, response) in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.api(httpResponse.statusCode, data) //TODO: map to error
            }
            return (data, httpResponse)
        }
        .eraseToAnyPublisher()
    }
}
