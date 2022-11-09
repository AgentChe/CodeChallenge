//
//  CollectionItemsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 23/08/2022.
//

import Foundation
import SwiftUI

struct CollectionItemsView: View {
    @EnvironmentObject var store: Store
    let collection: ChallengeGroup
    let onEnterDetails: (Challenge, ChallengeGroup?) -> Void

    var body: some View {
        DoodledView {
            VStack(alignment: .leading) {
                ZStack {
                    RoundedCornersShape(corners: [.topLeft, .topRight], radius: 10)
                        .fill(Color(.CodeChallenge.purple))
                        .frame(height: 69)
                    HStack {
                        Text(collection.name.removingPercentEncoding ?? collection.name)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 25)
                        .foregroundColor(.white)
                        .font(.systemFont(ofSize: 24, weight: .bold))
                        Spacer()
                    }
                }
                .frame(height: 69)

                VStack(alignment: .leading) {
                    Text(collection.description.removingPercentEncoding ?? collection.description)
                        .font(.systemFont(ofSize: 18))
                        .foregroundColor(.white)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 25)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(collection.challenges, id: \.id) { challenge in
                            UniversalCodeChallengeView(codeChallenge: challenge)
                                .onTapGesture {
                                    onEnterDetails(challenge, collection)
                                    store.dispatch(TrackAnalyticsEvent(event: .challengeSelected(challenge, collection, "Home")))
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}
