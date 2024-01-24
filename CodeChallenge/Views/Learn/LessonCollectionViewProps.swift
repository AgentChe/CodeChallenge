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
    
    var lessonCollectionProgress: LessonCollectionProgress? {
        store.state.lessonsProgress[learnElement.id]?.value
    }
    
    var chapterTitle: String? {
        store.state.learnSections[store.state.programmingLanguage]?.value?.contents.first(where: { learnSection in
            learnSection.contents.contains(where: { $0.id == learnElement.id })
        })?.title
    }

    var isLoading: Bool {
        store.state.lessons[learnElement.id]?.isLoading == true
    }
    
    var currentProgress: Int {
        lessonCollectionProgress?.currentProgress ?? 1
    }

    var enabledPages: [Lesson] {
        if hasPassedEntireLesson { return pages }
        return lessonCollection?.getEnabledPages(basedOn: currentProgress) ?? []
    }

    var pages: [Lesson] {
        lessonCollection?.pages ?? []
    }

    var passedIds: [Int] {
        store.state.learnSectionsProgress[programmingLanguage]?.value?.passedLessonIds ?? []
    }

    var lessonCollections: [LearnElement] {
        let sections = store.state.learnSections[programmingLanguage]?.value?.contents ?? []
        return sections
            .reduce([LearnElement](), { partialResult, result in
            partialResult + result.contents
        })
    }

    var nextLessonCollectionId: Int? {
        guard let currentIndex = (lessonCollections.firstIndex(where: { $0.id == lessonCollection?.id })) else { return nil }
        let index = lessonCollections.index(after: currentIndex)
        if index < lessonCollections.count - 1 {
            return lessonCollections[index].id
        } else {
            return nil
        }
    }

    var hasPassedEntireLesson: Bool {
        passedIds.contains(learnElement.id)
    }
}
