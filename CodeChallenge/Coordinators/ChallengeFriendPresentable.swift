//
//  ChallengeFriendPresentable.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 19/03/2023.
//

import Foundation
import UIKit
import SwiftUI

protocol ChallengeFriendPresentable: AnyObject {
    var store: Store { get }
    var challengeFriendNavigationController: UINavigationController? { get set }
}

extension ChallengeFriendPresentable {
    func startChallengeFriend(with data: ChallengeFriendData, from controller: UIViewController, onStart: @escaping () -> Void) {
        let hostingController = UIHostingController(rootView: ChallengeFriendContentsView(data: data, onStart: onStart).environmentObject(store))
        hostingController.view.backgroundColor = .CodeChallenge.dark
        challengeFriendNavigationController = UINavigationController(rootViewController: hostingController)
        challengeFriendNavigationController?.modalPresentationStyle = .overFullScreen
        challengeFriendNavigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if let challengeFriendNavigationController = challengeFriendNavigationController {
            controller.present(challengeFriendNavigationController, animated: true)
        }
    }
}
