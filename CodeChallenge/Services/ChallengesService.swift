//
//  ChallengesService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation
import Combine
import UIKit

protocol ChallengesServiceProtocol {
    func fetchChallengeGroups(id: Int, lang: String) -> AnyPublisher<[ChallengeGroup], Error>
    func fetchChallenge(id: Int) -> AnyPublisher<ChallengeDetail, Error>
    func getChallengeProgress(id: Int, userId: Int) -> AnyPublisher<ChallengeProgress, Error>
    func addChallengeProgress(id: Int, session: String, solution: String) -> AnyPublisher<ChallengeProgress, Error>
    func updateChallengeProgress(id: Int, progressId: Int, session: String, solution: String, type: String) -> AnyPublisher<Void, Error>
    func compile(id: Int, challengeId: Int, session: String) -> AnyPublisher<ChallengeCompiledResult, Error>
    func searchChallenges(with query: String, session: String) -> AnyPublisher<[Challenge], Error>
    func loadHashtags() -> AnyPublisher<[String], Error>

    func fetchHomeSections(language: String, humanLanguage: String, id: Int) -> AnyPublisher<[NewChallengeSection], Error>
    func fetchCollectionContent(id: Int, groupId: Int) -> AnyPublisher<NewChallengeCollectionContent, Error>
    func getRecommendedChallenges(userId: Int) -> AnyPublisher<[Challenge], Error>
}

struct ChallengesService: ChallengesServiceProtocol {
    let networkService: NetworkServiceProtocol

    func fetchChallengeGroups(id: Int, lang: String) -> AnyPublisher<[ChallengeGroup], Error> {
//        if let path = Bundle.main.url(forResource: "Challenges", withExtension: "json") {
//            do {
//                let jsonData = try Data(contentsOf: path)
//                let decoder = JSONDecoder.snakeCase
//                let challenges = try decoder.decode([ChallengeGroup].self, from: jsonData)
//                return Just(challenges).setFailureType(to: Error.self).eraseToAnyPublisher()
//            } catch {}
//        }
        return URLRequest
            .create(url: "\(Configuration.host)/home/\(id)/\(lang)", type: .get)
            .flatMap { networkService.load($0, decoding: [ChallengeGroup].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func fetchChallenge(id: Int) -> AnyPublisher<ChallengeDetail, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/challange/\(id)/en", type: .get)
            .flatMap { networkService.load($0, decoding: ChallengeDetail.self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func getChallengeProgress(id: Int, userId: Int) -> AnyPublisher<ChallengeProgress, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/challange/progress/get_id/\(userId)/\(id)", type: .get)
            .flatMap { networkService.load($0, decoding: ChallengeProgress.self, with: .init()) }
            .eraseToAnyPublisher()
    }

    func addChallengeProgress(id: Int, session: String, solution: String) -> AnyPublisher<ChallengeProgress, Error> {
        let solution = solution.stringByAddingPercentEncodingForRFC3986() ?? ""
        let params = ["challange_id": id, "session": session, "solution": ["python": "\(solution)"]] as [String : Any]
        return URLRequest
            .create(url: "\(Configuration.host)/challange/progress/add", type: .post, params: params)
            .flatMap { networkService.load($0, decoding: ChallengeProgress.self, with: .init()) }
            .eraseToAnyPublisher()
    }

    func updateChallengeProgress(id: Int, progressId: Int, session: String, solution: String, type: String) -> AnyPublisher<Void, Error> {
        let solution = solution.stringByAddingPercentEncodingForRFC3986() ?? ""
        let params = ["progress_id": progressId, "session": session, "solution": ["python": "\(solution)"], "spent_time": 10, "type": type] as [String : Any]
        return URLRequest
            .create(url: "\(Configuration.host)/challange/progress/update/", type: .post, params: params)
            .flatMap { networkService.send($0) }
            .eraseToAnyPublisher()
    }

    func compile(id: Int, challengeId: Int, session: String) -> AnyPublisher<ChallengeCompiledResult, Error> {
        let params = ["challangeId": challengeId, "session": session, "userId": id, "lang": "python", "inputs": ("{}".stringByAddingPercentEncodingForRFC3986() ?? "")] as [String: Any]
        return URLRequest
            .create(url: "\(Configuration.host)/compiler/", type: .post, params: params)
            .flatMap { networkService.load($0, decoding: ChallengeCompiledResult.self, with: .init()) }
            .eraseToAnyPublisher()
    }

    func searchChallenges(with query: String, session: String) -> AnyPublisher<[Challenge], Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/challange/search?search=\(query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? query)&lang_code=en", type: .get)
            .flatMap { networkService.load($0, decoding: [Challenge].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func loadHashtags() -> AnyPublisher<[String], Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/tags/", type: .get)
            .flatMap { networkService.load($0, decoding: [String].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func fetchHomeSections(language: String, humanLanguage: String, id: Int) -> AnyPublisher<[NewChallengeSection], Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/v1/home/\(id)/\(humanLanguage)", type: .get)
            .flatMap { networkService.load($0, decoding: [NewChallengeSection].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func fetchCollectionContent(id: Int, groupId: Int) -> AnyPublisher<NewChallengeCollectionContent, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/v1/challange/group/\(groupId)/\(id)", type: .get)
            .flatMap { networkService.load($0, decoding: NewChallengeCollectionContent.self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func getRecommendedChallenges(userId: Int) -> AnyPublisher<[Challenge], Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/challange/recomendations/\(userId)/en", type: .get)
            .flatMap { networkService.load($0, decoding: [Challenge].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }
}

extension String {
  func stringByAddingPercentEncodingForRFC3986() -> String? {
    let unreserved = "-._~/?"
    let allowed = NSMutableCharacterSet.alphanumeric()
    allowed.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
  }
}
