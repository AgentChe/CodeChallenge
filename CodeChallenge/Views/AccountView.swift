//
//  AccountView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import SwiftUI

struct AccountView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        VStack {
            Text("Hello logged in")
            Button("Sign out") {
                store.dispatch(Signout())
            }
        }
    }
}
