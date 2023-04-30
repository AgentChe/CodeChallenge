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

    var isLoading: Bool {
        store.state.learnSections[programmingLanguage]?.isLoading == true
    }

    var sections: [HomeSection] {
        store.state.learnSections[programmingLanguage]?.value?.contents ?? []
    }

    var currentProgressId: Int {
        store.state.learnSections[programmingLanguage]?.value?.currentProgress ?? 0
    }
}
