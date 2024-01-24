//
//  PracticeSectionsViewProps.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/03/2023.
//

import Foundation

protocol PracticeSectionsViewProps {
    var store: Store { get }
    var humanLanguage: String { get }
}

extension PracticeSectionsViewProps {
    var isLoading: Bool {
        store.state.practiceSections[identifier]?.isLoading == true
    }

    var sections: [ChallengeSection]? {
        store.state.practiceSections[identifier]?.value
    }
    
    var progresses: [IdProgressCouple]? {
        store.state.practiceSectionsProgresses[identifier]?.value
    }

    var identifier: String {
        "\(programmingLanguage.apiRequestParam)_\(humanLanguage)"
    }

    var programmingLanguage: ProgrammingLanguage {
        store.state.programmingLanguage
    }

    func progressImageName(index: Int, sectionIndex: Int) -> String {
        guard let collections = sections?[sectionIndex].collections else { return "" }
        if index == 0 && collections.count == 1 {
            return "practice_progress_only_section"
        } else if index == 0 {
            return "practice_progress_start"
        } else if index == collections.count - 1 {
            return "practice_progress_end"
        } else {
            return "practice_progress_middle"
        }
    }

    func progressTopInset(index: Int, sectionIndex: Int) -> CGFloat {
        guard let collections = sections?[sectionIndex].collections else { return 0 }
        if index == 0 && collections.count == 1 {
            return 23
        } else if index == 0 {
            return 21
        } else if index == collections.count - 1 {
            return 2
        } else {
            return 2
        }
    }

    func progressBottomInset(index: Int, sectionIndex: Int) -> CGFloat {
        guard let collections = sections?[sectionIndex].collections else { return 0 }
        if index == 0 && collections.count == 1 {
            return 26
        } else if index == 0 {
            return 2
        } else if index == collections.count - 1 {
            return 28
        } else {
            return 2
        }
    }

    func progressPreviousPeaceHeight(index: Int, sectionIndex: Int) -> CGFloat {
        guard let collections = sections?[sectionIndex].collections else { return 0 }
        if index == 0 && collections.count == 1 {
            return 0
        } else if index == 0 {
            return 0
        } else if index == collections.count - 1 {
            return 24
        } else {
            return 20
        }
    }

    func expectedHeight(index: Int, sectionIndex: Int) -> CGFloat {
        guard let collections = sections?[sectionIndex].collections else { return 0 }
        if index == 0 && collections.count == 1 {
            return 108
        } else if index == 0 {
            return 134
        } else if index == collections.count - 1 {
            return 104
        } else {
            return 134
        }
    }
}
