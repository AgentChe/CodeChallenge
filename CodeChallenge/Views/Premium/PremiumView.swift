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
    @State private var showMessage: String?

    var body: some View {
        Group {
            if let showMessage = showMessage {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(showMessage)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                content
            }
        }
            .background(.CodeChallenge.dark)
    }

    var content: some View {
        ScrollView(showsIndicators: false) {
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
                yearlyPaymentText
                PremiumNoteView(title: "How can I cancel?", text: "It’s easy: Open the Settings app, tap on your name, then tap on Subscriptions. Now select the Codehub Premium subscription and cancel it.")

                Button("Start my free trial now", action: {
                    if let yearlyPayment = yearlyPayment {
                        store.dispatch(PurchasePayment(payment: yearlyPayment))
                    }
                }).buttonStyle(GradientButton(status: buttonStatus))
                Spacer()
            }
            .padding(.horizontal, 25)
            .onAppear {
                store.dispatch(TrackAnalyticsEvent(event: .pricingOpened))
            }
        }
        .foregroundColor(.white)
    }

    var yearlyPaymentText: some View {
        VStack(alignment: .center, spacing: 20) {
            if let yearlyPayment = yearlyPayment {
                Group {
                    Text("Unlimited free access for 14 days, then ")
                        .font(.regular(size: 18)) +
                    Text("\(NumberFormatter.price(from: yearlyPayment.price.doubleValue)) annually ")
                        .font(.semibold(size: 18)) +
                    Text("(\(NumberFormatter.price(from: yearlyPayment.price.doubleValue/12))/month).")
                        .font(.regular(size: 18))
                }
                .foregroundColor(.white)
            }
            Button("View all plans") {
                onShowAllPlans(payments)
                store.dispatch(TrackAnalyticsEvent(event: .paywallOpened))
            }
            .foregroundColor(.CodeChallenge.blue1)
            .font(.h5)
        }
        .padding(.vertical, 10)
    }
}
