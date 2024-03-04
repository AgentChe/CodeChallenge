//
//  MaintenanceView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 31/10/2022.
//

import Foundation
import SwiftUI

struct MaintenanceView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                Image("maintenance")
                    .padding(.bottom, 88)
                HStack {
                    Spacer()
                        .frame(width: 34)
                    Text("Code Learning is currently down for maintenance")
                        .padding(.bottom, 17)
                        .font(.pageNameH1)
                        .multilineTextAlignment(.center)
                    Spacer()
                        .frame(width: 34)
                }
                HStack {
                    Spacer()
                        .frame(width: 34)
                    Text("Sorry, we’re down for scheduled maintenance right now. We’ll be back very soon, thanks for being with us. For questions please contact us at support@codehub.ninja")
                        .multilineTextAlignment(.center)
                        .font(.bodyText)
                    Spacer()
                        .frame(width: 34)
                }
                Spacer()
            }
            Spacer()
        }
        .foregroundColor(.white)
        .background(Color.dark.edgesIgnoringSafeArea(.all))
    }
}
