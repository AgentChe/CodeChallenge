//
//  BrowsedChallengesView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/08/2022.
//

import Foundation
import SwiftUI

struct BrowsedChallengesView: View, BrowsedChallengesViewProps {
    @EnvironmentObject var store: Store
    @Environment(\.instanceID) var instanceID
    let query: String
    let onEnterDetails: ((Challenge) -> Void)

    var body: some View {
        DoodledView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Results By \(query)")
                            .font(.systemFont(ofSize: 30, weight: .semibold))
                            .foregroundColor(.CodeChallenge.white)
                            .padding(.bottom, 20)
                            .lineLimit(1)
                        Spacer()
                    }

                    if !isLoading {
                        ForEach(challenges, id: \.challangeId) { challenge in
                            UniversalCodeChallengeView(codeChallenge: challenge)
                                .onTapGesture {
                                    onEnterDetails(challenge)
                                    store.dispatch(TrackAnalyticsEvent(event: .challengeSelected(challenge, nil, "Browse")))
                                }
                        }
                        Spacer()
                            .frame(height: 20)
                    } else {
                        BrowsedSkeletonView()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            store.dispatch(UpdateSearchQuery(query: query, instanceId: instanceID))
            store.dispatch(LoadSearchResults(instanceId: instanceID))
        }
    }
}

struct BrowsedSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.CodeChallenge.background))
            .frame(height: 76)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.CodeChallenge.background))
            .frame(height: 76)
        }
        .redacted(reason: .placeholder)
    }
}
