//
//  LessonCollectionViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 02/04/2023.
//

import Foundation

protocol LessonCollectionViewProps {
    var learnElement: LearnElement { get }
    var store: Store { get }
}

extension LessonCollectionViewProps {
    var programmingLanguage: ProgrammingLanguage {
        store.state.programmingLanguage
    }
    
    var lessonCollection: LessonCollection? {
        store.state.lessons[learnElement.id]?.value
    }

    var isLoading: Bool {
        store.state.lessons[learnElement.id]?.isLoading == true
    }
    
    var currentProgress: Int {
        lessonCollection?.currentProgress ?? 1
    }

    var enabledPages: [Lesson] {
        lessonCollection?.enabledPages ?? []
    }

    var pages: [Lesson] {
        lessonCollection?.pages ?? []
    }

    var lessonCollections: [LearnElement] {
        let sections = store.state.learnSections[.python]?.value?.contents ?? []
        return sections
            .reduce([LearnElement](), { partialResult, result in
            partialResult + result.contents
        })
    }

    var nextLessonCollectionId: Int? {
        guard let currentIndex = (lessonCollections.firstIndex(where: { $0.id == lessonCollection?.id })) else { return nil }
        let index = lessonCollections.index(after: currentIndex)
        return lessonCollections[index].id
    }
}
