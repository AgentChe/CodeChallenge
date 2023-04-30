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
    func fetchChallenge(id: Int) -> AnyPublisher<ChallengeDetail, Error>
    func getChallengeProgress(id: Int, userId: Int) -> AnyPublisher<ChallengeProgress, Error>
    func addChallengeProgress(id: Int, session: String, solution: String) -> AnyPublisher<ChallengeProgress, Error>
    func updateChallengeProgress(id: Int, progressId: Int, session: String, solution: String, type: String) -> AnyPublisher<Void, Error>
    func compile(id: Int, challengeId: Int, session: String, programmingLanguage: ProgrammingLanguage) -> AnyPublisher<ChallengeCompiledResult, Error>
    func searchChallenges(with query: String, programmingLanguage: ProgrammingLanguage, session: String) -> AnyPublisher<[Challenge], Error>
    func loadHashtags(programmingLanguage: ProgrammingLanguage) -> AnyPublisher<[String], Error>
    func fetchHomeSections(language: String, humanLanguage: String, id: Int) -> AnyPublisher<[ChallengeSection], Error>
    func fetchCollectionContent(id: Int, groupId: Int) -> AnyPublisher<ChallengeCollectionContent, Error>
    func getRecommendedChallenges(userId: Int, programmingLanguage: ProgrammingLanguage) -> AnyPublisher<[Challenge], Error>
    func getLearnSections(programmingLanguage: ProgrammingLanguage, session: String) -> AnyPublisher<LearnSections, Error>
    func getLessonCollection(id: Int, session: String) -> AnyPublisher<LessonCollection, Error>
    func updateClassProgress(session: String, classId: Int, progress: Int) -> AnyPublisher<Void, Error>
    func updatePathProgress(session: String, progress: Int, programmingLanguage: ProgrammingLanguage) -> AnyPublisher<Void, Error>
}

struct ChallengesService: ChallengesServiceProtocol {
    let networkService: NetworkServiceProtocol

    func fetchChallenge(id: Int) -> AnyPublisher<ChallengeDetail, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/v1/challange/\(id)/en", type: .get)
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

    func compile(id: Int, challengeId: Int, session: String, programmingLanguage: ProgrammingLanguage) -> AnyPublisher<ChallengeCompiledResult, Error> {
        let params = ["challangeId": challengeId, "userId": id] as [String: Any]
        return URLRequest
            .create(url: "\(Configuration.host)/compiler/\(programmingLanguage.rawValue)/", type: .post, params: params)
            .flatMap { networkService.load($0, decoding: ChallengeCompiledResult.self, with: .init()) }
            .eraseToAnyPublisher()
    }

    func searchChallenges(with query: String, programmingLanguage: ProgrammingLanguage, session: String) -> AnyPublisher<[Challenge], Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/v2/challange/search?search=\(query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? query)&hl=en&pl=\(programmingLanguage.apiRequestParam)", type: .get)
            .flatMap { networkService.load($0, decoding: [Challenge].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func loadHashtags(programmingLanguage: ProgrammingLanguage) -> AnyPublisher<[String], Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/v1/tags/\(programmingLanguage.apiRequestParam)/", type: .get)
            .flatMap { networkService.load($0, decoding: [String].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func fetchHomeSections(language: String, humanLanguage: String, id: Int) -> AnyPublisher<[ChallengeSection], Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/v2/home/\(id)/\(humanLanguage)/\(language)", type: .get)
            .flatMap { networkService.load($0, decoding: [ChallengeSection].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func fetchCollectionContent(id: Int, groupId: Int) -> AnyPublisher<ChallengeCollectionContent, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/v1/challange/group/\(groupId)/\(id)", type: .get)
            .flatMap { networkService.load($0, decoding: ChallengeCollectionContent.self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func getRecommendedChallenges(userId: Int, programmingLanguage: ProgrammingLanguage) -> AnyPublisher<[Challenge], Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/v1/challange/recomendations/\(userId)/en/\(programmingLanguage.apiRequestParam)", type: .get)
            .flatMap { networkService.load($0, decoding: [Challenge].self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func getLearnSections(programmingLanguage: ProgrammingLanguage, session: String) -> AnyPublisher<LearnSections, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/learning/learningPath/", type: .post, params: ["session": session, "pl": programmingLanguage.apiRequestParam])
            .flatMap { networkService.load($0, decoding: LearnSections.self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func getLessonCollection(id: Int, session: String) -> AnyPublisher<LessonCollection, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/learning/learningClass/", type: .post, params: ["session": session, "classId": id])
            .flatMap { networkService.load($0, decoding: LessonCollection.self, with: .snakeCase) }
            .eraseToAnyPublisher()
    }

    func updateClassProgress(session: String, classId: Int, progress: Int) -> AnyPublisher<Void, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/learning/updateClassProgress/", type: .post, params: ["session": session, "classId": classId, "progress": progress])
            .flatMap { networkService.send($0) }
            .eraseToAnyPublisher()
    }

    func updatePathProgress(session: String, progress: Int, programmingLanguage: ProgrammingLanguage) -> AnyPublisher<Void, Error> {
        return URLRequest
            .create(url: "\(Configuration.host)/learning/updatePathProgress/", type: .post, params: ["session": session, "pl": programmingLanguage.apiRequestParam, "progress": progress])
            .flatMap { networkService.send($0) }
            .eraseToAnyPublisher()
    }
}
