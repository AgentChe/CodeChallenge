//
//  NewHomeView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/11/2022.
//

import Foundation
import SwiftUI

struct NewHomeView: View, NewHomeViewProps {
    let gridItemLayout = [GridItem(.flexible())]
    @EnvironmentObject var store: Store
    let language: String
    let humanLanguage: String
    let onCollectionTap: ((NewChallengeCollection, NewChallengeSection) -> Void)?

    @State private var displaySections: [NewChallengeSection] = []

    var body: some View {
        DoodledView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Code Challenges")
                    .font(.systemFont(ofSize: 30, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 32)
                    .padding(.leading, 16)
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: gridItemLayout,
                        alignment: .leading,
                        spacing: 0,
                        pinnedViews: []) {
                            ForEach(displaySections, id: \.name) { section in
                                Section(
                                    header:
                                        Text(section.name)
                                        .font(.systemFont(ofSize: 18, weight: .semibold))
                                    .bold()
                                    .padding(.leading, 10.0)
                                    .padding(.bottom, 16)
                                ) {
                                    ForEach(section.collections, id: \.id) { collection in
                                        NewHomeViewElementView(model: collection)
                                            .onTapGesture {
                                                onCollectionTap?(collection, section)
                                            }
                                    }
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                }
            }
        }
        .onAppear {
            store.dispatch(LoadHomeSections(language: language, humanLanguage: humanLanguage))
            displaySections = sections ?? []
        }
        .onChange(of: sections) { newValue in
            displaySections = newValue ?? []
        }
    }
}

struct NewHomeViewElementView: View {
    let model: NewChallengeCollection

    var body: some View {
        HStack {
            Spacer()
                .frame(width: 44)
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(Color(UIColor.CodeChallenge.dark))
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(Color(model.progress == 100 ? .CodeChallenge.blue1 : .CodeChallenge.gray1), lineWidth: 1.5)
//                        .frame(width: .screenWidth - 32, height: 130)
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(model.name)
                                .font(.systemFont(ofSize: 18, weight: .medium))
                            Text(model.description)
                                .font(.systemFont(ofSize: 12))
                                .foregroundColor(Color(UIColor.white.withAlphaComponent(0.6)))
                        }
                        Spacer()
                        Image("test1")
                            .resizable()
                            .frame(width: 80, height: 80)
                        Spacer()
                            .frame(width: 5)
                    }
                    .padding(20)
                }
                Spacer()
                    .frame(height: 27)
            }
        }
    }
}
