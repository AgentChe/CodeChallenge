//
//  GetStartedView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 04/09/2022.
//

import Foundation
import SwiftUI

struct GetStartedView: View {
    @EnvironmentObject var store: Store
    let onDimiss: () -> Void

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image("doodle_cropped")
                    Spacer()
                }
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            VStack(alignment: .leading, spacing: 10) {
                Image("getStarted")
                    .frame(width: UIScreen.main.bounds.width)
                Group {
                    Spacer()
                    Text("Learn to code in 5 minutes a day")
                        .font(.pageNameH1)
                        .padding(.top, -90)
                    Text("Bringing you over 100 of the best free python coding challenges in a bite-sized format")
                        .font(.bodyText)
                    Spacer()
                    Button("Get Started") {
                        onDimiss()
                    }
                    .buttonStyle(PrimaryButton())
                    HStack {
                        Spacer()
                        getStartedDescribtion
                        Spacer()
                    }
                    Spacer()
                        .frame(height: UIDevice.hasSmallScreen ? 20 : 90)
                }
                .padding(.horizontal, 25)
            }
        }
        .background(Color.dark.edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.top)
        .foregroundColor(.white)
        .onAppear {
            store.dispatch(TrackAnalyticsEvent(event: .getStarted))
        }
    }

    private var getStartedDescribtion: some View {
        Button(action: {
            let tosURL = URL.init(string: "https://codehub.ninja/privacy/")!
            if UIApplication.shared.canOpenURL(tosURL) {
                UIApplication.shared.open(tosURL)
            }
        }, label: {
            (Text("By continuing, you agree to our ")
                + Text("Terms and Privacy Policy")
                    .underline()
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.regular(size: 12))
                .foregroundColor(Color.white)
                .fixedSize(horizontal: false, vertical: true)
        })
    }
}
