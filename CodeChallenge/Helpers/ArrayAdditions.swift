//
//  ArrayAdditions.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 12/11/2022.
//

import Foundation

extension Array {
    func element(at index: Int) -> Element? {
        if index >= self.count {
            return nil
        } else if index < 0 {
            return nil
        }
        return self[index]
    }
}
