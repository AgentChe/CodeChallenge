//
//  AccountService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 08/07/2022.
//

import Foundation
import Combine
import UIKit
import SwiftUI

protocol AccountServiceProtocol {
    func loadAccount(userId: Int) -> AnyPublisher<User, Error>
    func getFollowersCount(userId: Int) -> AnyPublisher<Int, Error>
    func getFollowingCount(userId: Int) -> AnyPublisher<Int, Error>
    func getChallengeProgress(userId: Int) -> AnyPublisher<[Challenge], Error>
    func addStreak(session: String) -> AnyPublisher<Void, Error>
    func uploadImage(session: String, imageData: Data) -> AnyPublisher<Void, Error>
}

struct AccountService: AccountServiceProtocol {
    let networkService: NetworkServiceProtocol

    func loadAccount(userId: Int) -> AnyPublisher<User, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/user/profile/\(userId)/\(userId)/", type: .get)
            .flatMap { networkService.load($0, decoding: User.self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func getFollowersCount(userId: Int) -> AnyPublisher<Int, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/follower/userFollowersCount/\(userId)", type: .get)
            .map { networkService.load($0, decoding: CountObject.self, with: .snakeCase) }
            .switchToLatest()
            .compactMap { $0.count }
            .eraseToAnyPublisher()
    }

    func getFollowingCount(userId: Int) -> AnyPublisher<Int, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/follower/userFollowingCount/\(userId)", type: .get)
            .map { networkService.load($0, decoding: CountObject.self, with: JSONDecoder()) }
            .switchToLatest()
            .compactMap { $0.count }
            .eraseToAnyPublisher()
    }

    func getChallengeProgress(userId: Int) -> AnyPublisher<[Challenge], Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/challange/progress/\(userId)/inprogress", type: .get)
            .flatMap { networkService.load($0, decoding: [Challenge].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func addStreak(session: String) -> AnyPublisher<Void, Error> {
        let params = ["session": session]
        return URLRequest
            .create(url: "\(Configuration.host)/user/addStreak", type: .post, params: params)
            .flatMap { networkService.send($0) }
            .eraseToAnyPublisher()
    }

    func uploadImage(session: String, imageData: Data) -> AnyPublisher<Void, Error> {
        let formFields = ["session": session]
        func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
          let data = NSMutableData()

          data.appendString("--\(boundary)\r\n")
          data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
          data.appendString("Content-Type: \(mimeType)\r\n\r\n")
          data.append(fileData)
          data.appendString("\r\n")

          return data as Data
        }

        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: URL(string: "\(Configuration.host)/user/uploadImage/")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let httpBody = NSMutableData()

        for (key, value) in formFields {
          httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }

        httpBody.append(convertFileData(fieldName: "file",
                                        fileName: "imagename.png",
                                        mimeType: "image/png",
                                        fileData: imageData,
                                        using: boundary))
        httpBody.appendString("--\(boundary)--")


        func convertFormField(named name: String, value: String, using boundary: String) -> String {
          var fieldString = "--\(boundary)\r\n"
          fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
          fieldString += "\r\n"
          fieldString += "\(value)\r\n"

          return fieldString
        }

        request.httpBody = httpBody as Data
        request.httpMethod = "POST"

        return Future<URLRequest, Error> { promise in
            promise(.success(request))
        }
        .share()
        .eraseToAnyPublisher()
        .flatMap { networkService.send($0) }
        .eraseToAnyPublisher()
    }
}

fileprivate struct CountObject: Codable {
    let count: Int

    enum CodingKeys: String, CodingKey {
        case count = "COUNT"
    }
}

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
