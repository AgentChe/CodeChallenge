//
//  LearnTabSectionsViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 04/04/2023.
//

import Foundation

protocol LearnTabSectionsViewProps {
    var store: Store { get }
}

extension LearnTabSectionsViewProps {
    var programmingLanguage: ProgrammingLanguage {
        store.state.programmingLanguage
    }

    var learnSections: LearnSections? {
        store.state.learnSections[programmingLanguage]?.value
    }

    var isLoading: Bool {
        store.state.learnSections[programmingLanguage]?.isLoading == true
    }

    var sections: [LearnSection] {
        learnSections?.contents ?? []
    }

    var currentProgressId: Int {
        learnSections?.currentProgress ?? 0
    }
}
