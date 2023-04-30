//
//  LessonCollectionViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 02/04/2023.
//

import Foundation

protocol LessonCollectionViewProps {
    var homeElement: HomeElement { get }
    var store: Store { get }
}

extension LessonCollectionViewProps {
    var lessonCollection: LessonCollection? {
        store.state.lessons[homeElement.id]?.value
    }
}
