//
//  InviteFriendsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 23/10/2022.
//

import Foundation
import SwiftUI
import UIKit
import Branch

struct InviteFriendsView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        DoodledView {
            content
        }
    }

    var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: UIDevice.hasSmallScreen ? 20 : 60) {
                Text("Bring your friends!")
                    .font(.pageNameH1)
                    .foregroundColor(.CodeChallenge.white)
                    .padding(.horizontal, 27)
                HStack {
                    Spacer()
                    Image("invite_friends_steps")
                    Spacer()
                }
                .padding(.horizontal, 25)
                Button("Invite your friends") {
                    inviteFriendsToggled()
                }
                    .buttonStyle(PrimaryButton())
                    .padding(.horizontal, 25)
                NoteView(text: "Did you know that more than a million people are currently on their coding journey? Join the Codehub Community and feel supported now!")
                    .padding(.horizontal, 25)
                Spacer()
            }
        }
        .foregroundColor(.white)
    }

    func inviteFriendsToggled() {
        let branchUniversalObject = BranchUniversalObject()
        branchUniversalObject.title = "Come learn Python with us!"
        branchUniversalObject.locallyIndex = false
        branchUniversalObject.imageUrl = "https://codehub.ninja/static/icon.jpg"
        branchUniversalObject.showShareSheet(withShareText: "Check it out!") { (activityType, completed) in
            if (completed) {
                print(String(format: "Completed sharing!"))
            } else {
                print("Link sharing cancelled")
            }
        }
    }
}
