//
//  SearchState.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 13/02/2023.
//

import Foundation

struct SearchState {
    let query: String?
    let results: Resolvable<[Challenge]>
    let hashtags: Resolvable<[String]>
}
