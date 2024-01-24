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
    
    var learnSectionsProgress: LearnSectionsProgress? {
        store.state.learnSectionsProgress[programmingLanguage]?.value
    }

    var isLoading: Bool {
        store.state.learnSections[programmingLanguage]?.isLoading == true
    }

    var sections: [LearnSection] {
        learnSections?.contents ?? []
    }

    var currentProgressId: Int {
        learnSectionsProgress?.currentProgress ?? 0
    }
    
    func getProgress(element: LearnElement) -> Double? {
        var result: Double? = nil
        learnSectionsProgress?.contents.forEach({ progress in
            if let progress = progress.contents.first(where: { $0.id == element.id })?.progress {
                result = progress
            }
        })
        return result
    }
}
