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
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Image("account_premium_doodle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200)
                        Spacer()
                    }
                }
                .frame(width: .screenWidth, height: .navbarBackgroundHeight, alignment: .center)
                .clipped()
                .background(.CodeChallenge.dark)
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
            .padding(.top, -50)
            .background(.CodeChallenge.dark)

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
        }
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

                Button("Start My 14-day Free Trial", action: {
                    if let yearlyPayment = yearlyPayment {
                        store.dispatch(PurchasePayment(payment: yearlyPayment))
                    }
                }).buttonStyle(PremiumGradientButton(status: buttonStatus))

                Button(action: {
                    store.dispatch(RestorePurchases(completionBlock: nil))
                }, label: {
                    (Text("By upgrading your account, you agree to the Terms of Service & Privacy Policy. ")
                        + Text("Restore purchases")
                            .underline()
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.regular(size: 12))
                        .foregroundColor(Color.white)
                        .fixedSize(horizontal: false, vertical: true)
                })

                Spacer()
            }
            .padding(.horizontal, 25)
            .onAppear {
                store.dispatch(TrackAnalyticsEvent(event: .paywallOpened))
            }
        }
        .foregroundColor(.white)
    }

    var yearlyPaymentText: some View {
        VStack(alignment: .center, spacing: 20) {
            if let yearlyPayment = yearlyPayment {
                Group {
                    Text("100+ Premium coding challenges. Unlimited access for 14 days, then ")
                        .font(.regular(size: 18)) +
                    Text("\(NumberFormatter.price(from: yearlyPayment.price.doubleValue, priceLocale: yearlyPayment.priceLocale)) annually.")
                        .font(.semibold(size: 18))
                }
                .foregroundColor(.white)
            }
            Button("View all plans") {
                onShowAllPlans(payments)
                store.dispatch(TrackAnalyticsEvent(event: .viewAllPlansClicked))
            }
            .foregroundColor(.CodeChallenge.blue1)
            .font(.h5)
        }
        .padding(.vertical, 10)
    }
}
