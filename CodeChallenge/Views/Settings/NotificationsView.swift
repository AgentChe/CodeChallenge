//
//  NotificationsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 21/08/2022.
//

import Foundation
import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        DoodledView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    HStack {
                        Text("Notifications")
                            .font(.systemFont(ofSize: 30, weight: .semibold))
                            .padding(.bottom, 10)
                        Spacer()
                    }

                    Spacer()
                }
                .foregroundColor(.CodeChallenge.white)
            }
            .padding(.horizontal, 27)
        }
    }
}
