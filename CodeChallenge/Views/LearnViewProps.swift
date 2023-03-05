//
//  LearnViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 05/03/2023.
//

import Foundation

protocol LearnViewProps {
    var store: Store { get }
    var sectionConceptReview: SectionConceptReview { get }
}

extension LearnViewProps {
    var pages: [ConceptReviewPage] {
        store.state.conceptReviews[sectionConceptReview.id]?.value?.body ?? []
    }

    var programmingLanguage: ProgrammingLanguage {
        store.state.programmingLanguage
    }
}
