//
//  String+RFC.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 14/02/2023.
//

import Foundation

extension String {
  func stringByAddingPercentEncodingForRFC3986() -> String? {
    let unreserved = "-._~/?"
    let allowed = NSMutableCharacterSet.alphanumeric()
    allowed.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
  }
}
