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
            VStack(spacing: 30) {
                Text("How your free trial works")
                    .foregroundColor(.white)
                    .font(.pageNameH1)
                HStack {
                    VStack {

                        Image("premium_progress")
                        Spacer()
                    }
                    Spacer()
                        .frame(width: 16)
                    VStack(alignment: .leading, spacing: 28) {
                        ForEach(getPremiumTexts, id: \.0) { (title, description) in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(title)
                                    .font(.h3)
                                    .foregroundColor(.white)
                                Text(description)
                                    .font(.bodyText)
                                    .foregroundColor(UIColor.lightGray)
                            }
                        }
                    }
                    Spacer()
                }
                VStack(spacing: 10) {
                    Text("Unlimited access for ...")
                        .foregroundColor(.white)
                        .font(.h4)
                    Button("View all plans") {
                        onShowAllPlans(payments)
                        store.dispatch(TrackAnalyticsEvent(event: .paywallOpened))
                    }
                    .foregroundColor(.CodeChallenge.blue1)
                    .font(.h5)
                }

                PremiumNoteView(title: "How can I cancel?", text: "hesht hangist")

                Button("Start my free trial now", action: {

                }).buttonStyle(GradientButton())
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
