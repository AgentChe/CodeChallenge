//
//  AppDelegate.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/06/2022.
//

import Foundation
import UIKit
import FirebaseCore
import Branch
import OtterScaleiOS

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        OtterScale.shared.initialize(host: GlobalDefinitions.otterScaleHost, apiKey: GlobalDefinitions.otterScaleApiKey)
        
        IAPManager.initialize()
        PurchaseValidationObserver.shared.startObserve()
        
        Branch.getInstance().initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { [weak self]
            (params, error) in
            if let params = params, (params["+is_first_session"] as? String) == "1",
                    let idString = params["referringUserID"] as? String {
                self?.sendReferralId(userId: idString)
                return
            }

            if let id = params?["challengeFriendId"] as? String, let intId = Int(id) {
                guard UserDefaults.standard.bool(forKey: "getStartedPresented") else {
                    UserDefaults.standard.set(intId, forKey: "challenge_friend_key")
                    return
                }
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.process(acceptedChallengeId: intId)
            }
        })

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

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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
