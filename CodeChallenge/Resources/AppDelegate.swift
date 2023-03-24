//
//  AppDelegate.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import Foundation
import UIKit
import OneSignal
import FirebaseCore
import Branch
import Paywall
import Mixpanel

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("d6f08880-5de1-4077-b5ec-82a962cff441")

        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notification: \(accepted)")
        })

        Branch.getInstance().initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { [weak self]
            (params, error) in
            if let params = params, (params["+is_first_session"] as? Int) == 1,
                    let idString = params["referringUserID"] as? String {
                self?.sendReferralId(userId: idString)
                return
            }

            if let id = params?["challengeFriendId"] as? Int {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.process(acceptedChallengeId: id)
            }
        })

        FirebaseApp.configure()
        Mixpanel.initialize(token: "4e8b61d12afcdad81dca5a29ef81425d")
        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor
        window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .portrait
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    let branchHandled = Branch.getInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
     if (!branchHandled) {
      // If not handled by Branch, do other deep link routing for the   Facebook SDK, Pinterest SDK, etc
      }
     return true
    }

    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    // pass the url to the handle deep link call
      Branch.getInstance().continue(userActivity)
     return true
    }
}

extension AppDelegate {
    private func sendReferralId(userId: String) {
        guard let url = URL(string: Configuration.host + "/invitation/accept/") else { return }
        let requestData = ["from": userId]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request)  { (_, _, _) in }.resume()
    }
}
