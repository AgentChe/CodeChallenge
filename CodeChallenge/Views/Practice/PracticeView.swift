//
//  NewPracticeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/11/2022.
//

import Foundation
import SwiftUI
import UIKit

struct PracticeView: View, PracticeViewProps {
    let gridItemLayout = [GridItem(.flexible(), spacing: 0)]
    @EnvironmentObject var store: Store
    let humanLanguage: String
    let onCollectionTap: ((ChallengeCollection) -> Void)?
    @State private var showProgrammingLanguagePopup = false

    @ObservedObject var searchFieldVM = FocusableSearchField.ViewModel()
    @State private var searchFieldIsFocused = false
    let onSearch: ((String) -> Void)?
    let onOpenChallenge: (Challenge) -> Void
    let onOpenPremium: () -> Void

    var body: some View {
        DoodledView {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Code Challenges")
                        .font(.pageNameH1)
                        .foregroundColor(.white)
                        .padding(.bottom, 16)
                        .padding(.leading, 16)
                    ScrollView(showsIndicators: false) {
                        searchBar
                            .padding(.vertical, 10)
                        if searchFieldIsFocused {
                            searchedResultView
                                .onAppear {
                                    store.dispatch(TrackAnalyticsEvent(event: .browseOpened))
                                }
                                .padding(.top, 10)
                        } else if isLoading {
                            SkeletonView()
                        } else {
                            PracticeSectionsView(humanLanguage: humanLanguage, onCollectionTap: onCollectionTap)
                        }
                    }
                }

                if showProgrammingLanguagePopup {
                    Rectangle()
                        .fill(Color.black)
                        .opacity(0.85)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showProgrammingLanguagePopup = false
                            }
                        }
                    changeLanguagePopup
                        .transition(.move(edge: .bottom).animation(.easeInOut(duration: 0.3)))
                        .zIndex(3)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 10) {
                    if store.state.maintenance?.premium == true, !isPremium {
                        HStack(spacing: 4) {
                            Text("Go Premium")
                                .foregroundColor(.CodeChallenge.white)
                                .font(.h5)
                            Image("challenge_premium_icon")
                                .resizable()
                                .frame(width: 14, height: 12)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .frame(height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.CodeChallenge.blue1))
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.CodeChallenge.dark)))
                            )
                            .onTapGesture {
                                store.dispatch(TrackAnalyticsEvent(event: AnalyticsEvent.goPremiumClicked))
                            }
                    }
                    LanguagePickerIconView()
                        .onTapGesture {
                            withAnimation {
                                showProgrammingLanguagePopup = true
                            }
                        }
                    DefaultXPView(
                        xpText: "\(xp)",
                        backgroundColor: .CodeChallenge.dark,
                        xpIconColor: "white",
                        strokeColor: .CodeChallenge.blue1
                    )
                }
            }
        }
        .onChange(of: programmingLanguage) { newValue in
            store.dispatch(LoadPracticeSections(language: newValue))
            store.dispatch(GetLearnSections(programmingLanguage: newValue))
        }
        .onChange(of: searchFieldVM.text) { newValue in
            store.dispatch(UpdateSearchQuery(query: newValue))
            store.dispatch(LoadSearchResults())
        }
        .onChange(of: searchFieldVM.isFocused) { newValue in
            searchFieldIsFocused = newValue
            store.dispatch(UpdateSearchQuery(query: searchFieldVM.text))
            store.dispatch(LoadSearchResults())
        }
    }

    private var searchBar: some View {
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

    @ViewBuilder
    private var searchedResultView: some View {
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
                                        store.dispatch(TrackAnalyticsEvent(event: .challengeSelected(challenge, "Browse", programmingLanguage)))
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
                                if !hashtags.isEmpty {
                                    KeywordsSwiftUIView(keywords: hashtags, onKeywordTap: { keyword in
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

    private var changeLanguagePopup: some View {
        VStack {
            Spacer()
            ZStack(alignment: .leading) {
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 10)
                    Text("Choose Language")
                        .font(.h2)
                        .padding(.horizontal, 4)
                    ForEach(ProgrammingLanguage.allCases, id: \.rawValue) { language in
                        languageView(language: language)
                            .padding(.horizontal, 20)
                            .onTapGesture {
                                store.dispatch(ChangeProgrammingLanguage(language: language))
                                store.dispatch(LoadRecommendedChallenges())
                                withAnimation {
                                    showProgrammingLanguagePopup = false
                                }
                            }
                            .contentShape(Rectangle())
                    }
                    Button("Cancel") {
                        withAnimation {
                            showProgrammingLanguagePopup.toggle()
                        }
                    }
                    .foregroundColor(.white.withAlphaComponent(0.6))
                    .font(.smallText)
                    .padding(.bottom, 20)
                }
                .foregroundColor(.white)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.CodeChallenge.background))
                }
            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .frame(width: .screenWidth)
    }

    private func languageView(language: ProgrammingLanguage) -> some View {
        HStack(spacing: 12) {
            Image(language.rawValue)
                .resizable()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 7) {
                Text(language.rawValue.capitalized)
                    .font(.h5)
                Text(language.shortDescription)
                    .font(.smallText)
                    .foregroundColor(.white.withAlphaComponent(0.6))
            }
            Spacer()
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(UIColor.CodeChallenge.purple), lineWidth: 1.2)
        }
    }
}

fileprivate struct SkeletonView: View {
    let gridItemLayout = [GridItem(.flexible(), spacing: 0)]
    let model1 = ChallengeCollection(id: 1)
    let model2 = ChallengeCollection(id: 2)
    let model3 = ChallengeCollection(id: 3)
    let model4 = ChallengeCollection(id: 4)
    let model5 = ChallengeCollection(id: 5)

    var body: some View {
        LazyVGrid(
            columns: gridItemLayout,
            alignment: .leading,
            spacing: 0,
            pinnedViews: []) {
                Section(
                    header:
                        Text("something")
                        .font(.h3)
                        .bold()
                        .padding(.leading, 10.0)
                        .padding(.bottom, 16)
                ) {
                    PracticeViewElementView(
                        model: model1, progressImageName: "practice_progress_start",
                        progressTopInset: 21, progressBottomInset: 2,
                        progressPreviousPeaceHeight: 0, expectedHeight: 134,
                        previousModel: nil, nextModel: model2
                    )
                    PracticeViewElementView(
                        model: model2, progressImageName: "practice_progress_end",
                        progressTopInset: 2, progressBottomInset: 28,
                        progressPreviousPeaceHeight: 24, expectedHeight: 104,
                        previousModel: model1, nextModel: model3
                    )
                }
                Section(
                    header:
                        Text("something 2")
                        .font(.h3)
                        .bold()
                        .padding(.leading, 10.0)
                        .padding(.bottom, 16)
                ) {
                    PracticeViewElementView(
                        model: model4, progressImageName: "practice_progress_only_section",
                        progressTopInset: 23, progressBottomInset: 26,
                        progressPreviousPeaceHeight: 0, expectedHeight: 108,
                        previousModel: nil, nextModel: model5
                    )
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .redacted(reason: .placeholder)
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
