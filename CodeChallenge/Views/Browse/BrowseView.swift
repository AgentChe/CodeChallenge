//
//  BrowseView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 07/07/2022.
//

import Foundation
import SwiftUI

struct BrowseView: View, BrowseViewProps {
    @ObservedObject var searchFieldVM = FocusableSearchField.ViewModel()
    let onSearch: ((String) -> Void)?
    let onOpenChallenge: (Challenge) -> Void
    @Environment(\.instanceID) var instanceID
    @EnvironmentObject var store: Store
    @State private var searchFieldIsFocused = false
    @State private var displayHashtags: [String] = []

    var body: some View {
        DoodledView {
            VStack(alignment: .leading, spacing: 40) {
                Text("Browse")
                    .font(.pageNameH1)
                    .foregroundColor(.CodeChallenge.white)
                    .padding(.horizontal, 20)
                searchBar

                if challengesToSuggest.isEmpty && !searchFieldVM.text.isEmpty && !challengesAreLoading {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image("challenges_not_found_icon")
                                Spacer()
                            }
                            Spacer()
                        }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 40) {
                            if !challengesToSuggest.isEmpty && searchFieldIsFocused {
                                VStack(spacing: 10) {
                                    ForEach(challengesToSuggest, id: \.id) { challenge in
                                        UniversalCodeChallengeView(codeChallenge: challenge)
                                            .onTapGesture {
                                                onOpenChallenge(challenge)
                                                store.dispatch(TrackAnalyticsEvent(event: .challengeSelected(challenge, nil, "Browse")))
                                            }
                                    }
                                }
                                .padding(.horizontal, 20)
                            } else {
                                if challengesToSuggest.isEmpty && !searchFieldVM.text.isEmpty {
                                    if challengesAreLoading {
                                        SkeletonSearchResultsView()
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 15) {
                                        Text("By hashtag")
                                            .foregroundColor(.white)
                                            .font(.h4)
                                            .padding(.horizontal, 20)
                                        if !displayHashtags.isEmpty {
                                            KeywordsSwiftUIView(keywords: displayHashtags, onKeywordTap: { keyword in
                                                store.dispatch(TrackAnalyticsEvent(event: .challengeSearched(keyword, "keyword")))
                                                onSearch?(keyword)
                                            })
                                                .background(.clear)
                                        }
                                        RecommendationsView(onChallengeTap: onOpenChallenge)
                                            .padding(.top, 10)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                store.dispatch(TrackAnalyticsEvent(event: .browseOpened))
                DispatchQueue.main.async {
                    displayHashtags = hashtags
                }
            }
        }
        .onChange(of: searchFieldVM.text) { newValue in
            store.dispatch(UpdateSearchQuery(query: newValue, instanceId: instanceID))
            store.dispatch(LoadSearchResults(instanceId: instanceID))
        }
        .onChange(of: searchFieldVM.isFocused) { newValue in
            searchFieldIsFocused = newValue
            store.dispatch(UpdateSearchQuery(query: searchFieldVM.text, instanceId: instanceID))
            store.dispatch(LoadSearchResults(instanceId: instanceID))
        }
        .onChange(of: hashtags) { newValue in
            DispatchQueue.main.async {
                displayHashtags = newValue
            }
        }
    }

    var searchBar: some View {
        VStack {
            HStack {
                FocusableSearchField(viewModel: searchFieldVM) {
                    if !searchFieldVM.text.isEmpty {
                        store.dispatch(TrackAnalyticsEvent(event: .challengeSearched(searchFieldVM.text, "manual")))
                        onSearch?(searchFieldVM.text)
                    }
                }
                    .frame(height: 48)

                if searchFieldVM.isSearchEnabled {
                    Button {
                        searchFieldVM.isFocused = false
                        searchFieldVM.text = ""
                    } label: {
                        Text("Cancel")
                            .font(.regular(size: 16))
                            .foregroundColor(.CodeChallenge.white)
                            .accessibilityLabel("cancel")
                            .accessibilityHint("cancel search")
                    }
                    .padding(.trailing, 10)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct SkeletonSearchResultsView: View {
    var body: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.CodeChallenge.background))
                .frame(height: 76)
                .padding(.horizontal, 20)

            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.CodeChallenge.background))
                .frame(height: 76)
                .padding(.horizontal, 20)

            Spacer()
        }
        .redacted(reason: .placeholder)
    }
}
