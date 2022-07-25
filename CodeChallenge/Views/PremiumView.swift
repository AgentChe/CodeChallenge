//
//  PremiumView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation
import SwiftUI

struct PremiumView: View, PremiumViewProps {
    @EnvironmentObject var store: Store
    @State var showOverlay = false
    var onShowAllPlans: ([AppStorePayment]) -> Void

    var body: some View {
        DoodledView {
            content
        }
    }

    var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Image("premium")
                Text("Start 7-Day Free Trial Today and Now")
                    .font(.systemFont(ofSize: 24, weight: .bold))
                ForEach(getPremiumTexts, id: \.self) { text in
                    HStack(spacing: 15) {
                        Image("checkmark")
                        Text(text)
                            .font(.systemFont(ofSize: 16, weight: .regular))
                    }
                }
                VStack(alignment: .center, spacing: 8) {
                    Button("Start now") {

                    }
                    .buttonStyle(PrimaryButton())
                    Text("ari vercru, heto kmtacenq, hesa reccession-a shut ara")
                        .font(.systemFont(ofSize: 12, weight: .regular))

                    Button("VIEW ALL PLANS") {
                        onShowAllPlans(payments)
                        store.dispatch(TrackAnalyticsEvent(event: .paywallOpened))
                    }
                    .foregroundColor(.CodeChallenge.blue1)
                    .padding(.top, 32)
                    .font(.systemFont(ofSize: 20, weight: .bold))
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding(.horizontal, 25)
            .onAppear {
                store.dispatch(TrackAnalyticsEvent(event: .pricingOpened))
            }
        }
        .foregroundColor(.white)
    }
}
