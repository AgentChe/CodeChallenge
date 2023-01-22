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

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("d6f08880-5de1-4077-b5ec-82a962cff441")

        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notification: \(accepted)")
        })

        Branch.getInstance().initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { (params, error) in
            print("BranchSDK", params, error)
        })

        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }

        Branch.getInstance().setIdentity(UIDevice.current.identifierForVendor?.uuidString ?? "")

        FirebaseApp.configure()
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
