//
//  LearnView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 01/03/2023.
//

import Foundation
import SwiftUI
import Highlightr

struct LessonView: View, LearnViewProps {
    @EnvironmentObject var store: Store
    @Environment(\.presentationMode) var presentationMode
    let sectionConceptReview: SectionConceptReview
    let spacing: CGFloat = 16
    let widthOfHiddenCards: CGFloat = 10
    @State var activeCard: Int = 0
    @State var screenDrag: Float = 0.0
    
    var body: some View {
        VStack(spacing: 10) {
            header
            Carousel(
                numberOfItems: CGFloat(pages.count),
                spacing: spacing,
                widthOfHiddenCards: widthOfHiddenCards,
                screenDrag: $screenDrag,
                activeCard: $activeCard
            ) {
                ForEach(Array(pages.enumerated()), id: \.offset) { (index, item) in
                    VStack {
                        Spacer()
                            .frame(height: index == activeCard ? 10 : 40)
                        ZStack {
                            RoundedCornersShape(corners: [.topLeft, .topRight], radius: 25)
                                .fill(.white)
                            itemView(item)
                        }
                        .frame(width: .screenWidth - (widthOfHiddenCards*2) - (spacing*2) , alignment: .center)
                    }
                    .foregroundColor(Color.black)
                    .transition(AnyTransition.slide)
                    .animation(.easeInOut(duration: 0.25), value: UUID())
                }
            }
        }
        .background(Color.dark.edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.bottom)
    }

    private var header: some View {
        ZStack {
            PageControl(currentPageIndex: $activeCard, numberOfPages: pages.count)
                .padding(.horizontal, 50)
            HStack {
                Spacer()
                    .frame(width: 16)
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("back")
                }

                Spacer()
            }
        }
    }

    private func itemView(_ item: ConceptReviewPage) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.title)
                    .font(.h2)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                ForEach(Array(item.components.enumerated()), id: \.offset) { _, item in
                    switch item.type {
                    case .text:
                        Text(item.value)
                            .padding(.horizontal, 25)
                            .font(.h5)
                            .multilineTextAlignment(.leading)
                    case .code:
                        ZStack {
                            Rectangle()
                                .fill(Color(UIColor.CodeChallenge.darkBlue))
                            if let attributedString = getCodeAttributedString(code: item.value) {
                                HStack {
                                    Spacer()
                                        .frame(width: 25)
                                    HtmlAttributedLabel(htmlAttributedString: attributedString, foregroundColor: nil, inset: codeBlockInsets)
                                        .frame(width: .screenWidth - CGFloat(codeBlockInsets))
                                    Spacer()
                                        .frame(width: 25)
                                }
                                .padding(.vertical, 16)
                            }
                        }
                    case .note:
                        NoteView(text: item.value)
                            .padding(.horizontal, 25)
                    case .image:
                        NetworkImage(viewModel:
                                .init(url: "\(Configuration.host)/concept_review/getImage/\(item.value)/",
                                      store: store),
                                     size: .init(
                                    width: .screenWidth - (widthOfHiddenCards*2) - (spacing*2),
                                    height: .screenHeight / 4), contentMode: .fit)
                    }
                }
                Spacer()
                    .frame(height: 30)
            }
        }
        .frame(width: .screenWidth - (widthOfHiddenCards*2) - (spacing*2) , alignment: .center)
    }

    private var codeBlockInsets: Int {
        Int((widthOfHiddenCards*2) + (spacing*2) + 50)
    }

    private func getCodeAttributedString(code: String) -> NSMutableAttributedString? {
        let highlightr = Highlightr()
        highlightr?.setTheme(to: "atom-one-dark-reasonable")
        // You can omit the second parameter to use automatic language detection.
        guard let highlightedCode = highlightr?.highlight(code, as: programmingLanguage.rawValue) else { return nil }
        return NSMutableAttributedString(attributedString: highlightedCode)
    }
}
