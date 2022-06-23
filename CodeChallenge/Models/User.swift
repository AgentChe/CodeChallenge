//
//  User.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation

struct User: Decodable {
    let id: Int?
    let session: String?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case id, session, username
    }

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        id = try? container?.decodeIfPresent(Int.self, forKey: .id)
        session = try? container?.decodeIfPresent(String.self, forKey: .session)
        username = try? container?.decodeIfPresent(String.self, forKey: .username)
    }
}
