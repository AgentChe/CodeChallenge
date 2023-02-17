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
    @State private var selection = 1

    var body: some View {
        DoodledView {
            content
        }
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 10) {
            SegmentedControlView(
                selection: $selection,
                sections: ["Rewards Store", "Invite Friend"],
                onValueChange: { selection in
                self.selection = selection
            })
            .padding(.horizontal, 9)
            .frame(height: 31)
            Text("Invite Your friend. Study free for a year.")
                .font(.semibold(size: 30))
            Text("You will both get rewarded $10 when your friend places their first Instacart order. Terms apply")
                .font(.regular(size: 14))
            Text("Here's your invite link")
                .padding(.top, 30)
                .font(.semibold(size: 18))
                .padding(.bottom, 6)
            HStack(spacing: 10) {
                HStack {
                    Text("random")
                        .font(.regular(size: 14))
                        .padding(16)
                    Spacer()
                    Button("Copy") {
                        UIPasteboard.general.string = "random"
                    }
                    .foregroundColor(.CodeChallenge.blue1)
                    .padding(.trailing, 14)
                    .font(.semibold(size: 18))
                }.background{
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.CodeChallenge.dustyBlue), lineWidth: 1)
                }
                .frame(height: 46)

                Button {
                    inviteFriendsToggled()
                } label: {
                  Text("Share")
                        .padding(14)
                        .background(.CodeChallenge.blue1)
                        .font(.semibold(size: 18))
                        .cornerRadius(8)
                        .frame(height: 46)
                }
            }
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
    }

    func inviteFriendsToggled() {
        let branchUniversalObject = BranchUniversalObject()
        branchUniversalObject.title = "Come learn coding with us!"
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
