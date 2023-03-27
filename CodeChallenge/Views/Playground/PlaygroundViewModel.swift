//
//  PlaygroundViewModel.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 10/03/2023.
//

import Foundation
import UIKit

class PlaygroundViewModel {
    enum UpdateType {
        case codeChange(String)
        case languageUpdate(ProgrammingLanguage)
        case updateTextView(Bool)
        case updateCharactersInRange(NSRange, String)
        case workMatchesRetrieved([String], NSRange)
        case updateTextViewCursor(offset: Int)
        case highlight(NSRange, UIColor)
    }

    private let autocompleteSymbols = ["(":")", "{":"}", "[":"]", "\"":"\"", "\'":"\'"]
    private var codeToCompile: String = "" {
        didSet {
            onCodeChange?(codeToCompile)
        }
    }
    var language: ProgrammingLanguage = .python
    var aiGenerated: [AIGenerated] = []
    var onCodeChange: ((String) -> Void)?
    var onUpdate: ((UpdateType) -> Void)?
    var aiEnabled: Bool = true

    init(language: ProgrammingLanguage, aiGenerated: [AIGenerated], onCodeChange: ((String) -> Void)?, aiEnabled: Bool) {
        self.language = language
        self.aiGenerated = aiGenerated
        self.onCodeChange = onCodeChange
        self.aiEnabled = aiEnabled
    }

    func set(code: String) {
        codeToCompile = code.removingPercentEncoding ?? code
        onUpdate?(.codeChange(code.removingPercentEncoding ?? code))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { [weak self] in
            self?.onUpdate?(.updateTextView(true))
        }
    }

    func onSelect(specialCharacter: String, range: NSRange) {
        self.onUpdate?(.updateCharactersInRange(range, specialCharacter))
        self.onUpdate?(.updateTextViewCursor(offset: specialCharacter.count))
        codeToCompile = (codeToCompile as NSString).replacingCharacters(in: range, with: "\(specialCharacter)")
        if let value = self.autocompleteSymbols[specialCharacter] {
            let newRange = NSRange(location: range.location + range.length + specialCharacter.count, length: 0)
            codeToCompile = (codeToCompile as NSString).replacingCharacters(in: newRange, with: value)
            onUpdate?(.updateCharactersInRange(newRange, value))
        }
        self.onUpdate?(.updateTextView(true))
    }

    func update(codeToCompile: String) {
        self.codeToCompile = codeToCompile
    }

    func proceed(with text: String, in range: NSRange, textViewText: String) -> Bool {
        if text == "\n" {
            let tabs = newTabs(text: textViewText, range: range)
            self.onUpdate?(.updateCharactersInRange(range, "\n\(tabs)"))
            self.onUpdate?(.updateTextViewCursor(offset: "\n\(tabs)".count))
            self.onUpdate?(.updateTextView(true))
            codeToCompile = (codeToCompile as NSString).replacingCharacters(in: range, with: "\n\(tabs)")
            return false
        } else if codeToCompile.count >= range.upperBound, text != "" {
            codeToCompile = (codeToCompile as NSString).replacingCharacters(in: range, with: text)
            let (word, wordRange) = findWordBetweenSpaces(using: range, in: codeToCompile.replacingOccurrences(of: "\t", with: " ").replacingOccurrences(of: "\n", with: " "))
            if !word.isEmpty && text != " " {
                autocomplete(phrase: word, range: wordRange)
            }

            if let value = self.autocompleteSymbols[text] {
                codeToCompile = (codeToCompile as NSString).replacingCharacters(in: range, with: value)
                onUpdate?(.updateCharactersInRange(range, value))
            }
        } else {
            codeToCompile = (codeToCompile as NSString).replacingCharacters(in: range, with: text)
        }
        return true
    }

    private func newTabs(text: String, range: NSRange) -> String {
        var linesBefore: [String] = []
        text.prefix(range.location).enumerateLines(invoking: { line, stop in
            linesBefore.append(line)
        })
        let lastLineTabs = linesBefore.last { $0.last == language.openingSymbol }?.prefix(while: { $0 == " " }) ?? ""
        let evenNumberTabs = lastLineTabs.count % 2 == 0 ? lastLineTabs : lastLineTabs.prefix(lastLineTabs.count - 1)
        let newTab = linesBefore.last { $0.last == language.openingSymbol } != nil ? "  " : ""
        return "\(evenNumberTabs)\(newTab)"
    }

    private func findWordBetweenSpaces(using range: NSRange, in text: String) -> (String, NSRange) {
        let prefix = (text.prefix(range.lowerBound).lastIndex { $0 == " " })?.utf16Offset(in: text) ?? 0
        let suffix: Int
        if text.count - range.upperBound > 0 {
            suffix = (text.suffix(text.count - range.upperBound).firstIndex { $0 == " " })?
                .utf16Offset(in: text) ?? text.count
        } else {
            suffix = text.count
        }
        let range = String.Index(utf16Offset: min(prefix + 1, text.count), in: text)..<String.Index(utf16Offset: suffix, in: text)
        return (String(text[range]), NSRange(range, in: text))
    }

    private func autocomplete(phrase: String, range: NSRange) {
        let matches = AutocompleteTermsHelper.getMatches(string: phrase, language: language.rawValue)
        let matchesWithoutPhrase = matches.filter { $0 != phrase }

        if !matchesWithoutPhrase.isEmpty {
            onUpdate?(.workMatchesRetrieved(matchesWithoutPhrase, range))
        }
    }

    func autocomplete(with phrase: String, range: NSRange) {
        self.codeToCompile = (self.codeToCompile as NSString).replacingCharacters(in: range, with: phrase)
        onUpdate?(.updateCharactersInRange(range, phrase))
        onUpdate?(.updateTextViewCursor(offset: phrase.count - (range.upperBound - range.lowerBound)))
        onUpdate?(.updateTextView(true))
    }

    func applyHighlightingIfNeeded(string: NSString) {
        guard aiEnabled else { return }
        var lineRanges = [(String, NSRange)]()
        string.enumerateSubstrings(
            in: NSRange(location: 0, length: string.length)
        ) { [weak self] (text, lineRange, _, _) in
            if self?.showGenerateByAI(for: text ?? "") == true {
                lineRanges.append((text ?? "", lineRange))
            }
        }

        lineRanges
            .forEach { (_, range) in
                onUpdate?(.highlight(range, .CodeChallenge.darkBlue))
            }
    }

    func showGenerateByAI(for line: String) -> Bool {
        guard aiEnabled else { return false }
        let value = line.replacingOccurrences(of: " ", with: "")
        return (self.aiGenerated.compactMap { $0.comment.removingPercentEncoding?
            .replacingOccurrences(of: " ", with: "") }.contains(value) == true)
    }

    func generateWithAI(for comment: String, lineNumber: Int, text: NSString?) {
        guard let string = text, aiEnabled else { return }
        let value = comment.replacingOccurrences(of: " ", with: "")
        let comment = aiGenerated.first { $0.comment.removingPercentEncoding?
            .replacingOccurrences(of: " ", with: "") == value }?.code.randomElement()?.removingPercentEncoding ?? ""

        var lineRanges = [(String, NSRange)]()
        string.enumerateSubstrings(
            in: NSRange(location: 0, length: string.length)
        ) { (text, lineRange, _, _) in
            lineRanges.append((text ?? "", lineRange))
        }
        let range = lineRanges[lineNumber].1
        onUpdate?(.updateCharactersInRange(range, comment))
        onUpdate?(.updateTextView(false))
    }
}
