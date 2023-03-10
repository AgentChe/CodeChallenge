//
//  PlaygroundView.swift
//  CC
//
//  Created by Tatevik Tovmasyan on 25/05/2022.
//

import Foundation
import UIKit
import SwiftUI
import Highlightr

class PlaygroundView: UIView {
    enum Constants {
        static let autocompleteMaximumWordCharCount: CGFloat = 10
        static let autocompleteDropdownItemHeight: CGFloat = 26
        static let autocompleteDropdownItemWidth: CGFloat = 200
        static let lineNumberBoxWidth: CGFloat = 35
        static let scrollViewTopInset: CGFloat = 20
        static let fontSize: CGFloat = UIDevice.hasSmallScreen ? 15 : 16
    }
    let textView: UITextView = {
        let textStorage = CodeAttributedString()
        textStorage.highlightr.setTheme(to: "atom-one-dark-reasonable")
        textStorage.highlightr.theme.setCodeFont(UIFont(name: "CourierNewPSMT", size: Constants.fontSize)!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: .init(width: UIScreen.main.bounds.width - 10 - Constants.lineNumberBoxWidth, height: UIScreen.main.bounds.size.height - 260))
        layoutManager.addTextContainer(textContainer)

        let textView = UITextView(frame: .zero, textContainer: textContainer)
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.autocapitalizationType = .none
        textView.smartQuotesType = .no
        textView.keyboardType = .asciiCapable
        textView.autocorrectionType = .no
        return textView
    }()

    private let autocompleteSymbols = ["(":")", "{":"}", "[":"]", "\"":"\"", "\'":"\'"]

    private var textViewHeightConstraint: NSLayoutConstraint?
    private var autocompleteDropdownHostingController: UIViewController?
    private var codeToCompile: String = ""
    private var scrollViewBottomConstraint: NSLayoutConstraint?
    private var justAutocompleted: Bool = false
    private var fontHeight: CGFloat = UIFont(name: "CourierNewPSMT", size: Constants.fontSize)?.lineHeight ?? 0
    var language: ProgrammingLanguage = .python {
        didSet {
            (textView.textStorage as? CodeAttributedString)?.language = language.rawValue
        }
    }
    var aiGenerated: [AIGenerated] = []
    var onCodeChange: ((String) -> Void)?

    private let lineNumerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.backgroundColor = .clear
        return stackView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func set(code: String) {
        self.codeToCompile = code.removingPercentEncoding ?? code
        self.codeToCompile = codeToCompile.replacingOccurrences(of: "\t", with: "  ")
        self.codeToCompile = codeToCompile.replacingOccurrences(of: "\n", with: " ")
        textView.text = code.removingPercentEncoding ?? code
    }

    func reset(newCode: String) {
        set(code: newCode)
        textViewDidChange(textView)
    }

    func commonInit() {
        setupViews()
        codeToCompile = textView.text

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textViewDidChange(self.textView)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(onDismissKeyboard))
        self.addGestureRecognizer(tap)
    }

    @objc func onDismissKeyboard() {
        if !justAutocompleted {
            self.textView.resignFirstResponder()
        }
        justAutocompleted = false
    }

    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            scrollViewBottomConstraint?.constant = -keyboardHeight + (UIDevice.hasSmallScreen ? 65 : 95) - 10 + (UIDevice.hasDisplayNotch ? 0 : 34)

            self.setNeedsLayout()
            self.layoutIfNeeded()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.textViewDidChange(self.textView)
            }
        }
    }

    @objc func keyboardWillHide() {
        scrollViewBottomConstraint?.constant = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textViewDidChange(self.textView)
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}


extension PlaygroundView {
    private func setupViews() {
        let hStackView = UIStackView(arrangedSubviews: [lineNumerStackView, textView])
        hStackView.axis = .horizontal

        scrollView.addSubview(hStackView)
        self.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        hStackView.translatesAutoresizingMaskIntoConstraints = false

        let justView = UIView(frame: .init(x: 0, y: 0, width: Constants.lineNumberBoxWidth, height: Constants.lineNumberBoxWidth))
        justView.backgroundColor = .blue

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.scrollViewTopInset),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            hStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            lineNumerStackView.widthAnchor.constraint(equalToConstant: Constants.lineNumberBoxWidth),
            justView.heightAnchor.constraint(equalToConstant: Constants.lineNumberBoxWidth),
            textView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - Constants.lineNumberBoxWidth - 20),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.lineNumberBoxWidth + 10)
        ])

        scrollViewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        scrollViewBottomConstraint?.isActive = true

        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: Constants.lineNumberBoxWidth)
        textViewHeightConstraint?.isActive = true
        textView.delegate = self

        lineNumerStackView.addArrangedSubview(justView)
    }

    private func setupLineNumbers(height: CGFloat) {
        lineNumerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let endIndex = Int(ceil(height/(fontHeight))) - 1
        var lines: [String] = []
        (textView.text as? NSString)?.enumerateLines({ line, stop in
            lines.append(line)
        })

        // a weird workaround
        if textView.text.last == "\n" {
            lines += ["a"]
        }
        let lineNumbers = getLineClusters(basedOn: endIndex, lines: lines)
        print(lineNumbers)
        for i in lineNumbers {
            let label = UILabel()
            label.font = UIFont(name: "CourierNewPSMT", size: Constants.fontSize)
            label.text = "\(i)"
            label.textColor = i != 0 ? .white : .clear
            let hstack = UIStackView()
            hstack.axis = .horizontal
            hstack.addArrangedSubview(label)
            hstack.addArrangedSubview(UIView())
            let separatorView = UIView()
            separatorView.backgroundColor = .CodeChallenge.blue1
            hstack.addArrangedSubview(separatorView)
            NSLayoutConstraint.activate([
                separatorView.widthAnchor.constraint(equalToConstant: 1),
                hstack.widthAnchor.constraint(equalToConstant: Constants.lineNumberBoxWidth),
                hstack.heightAnchor.constraint(equalToConstant: fontHeight)
            ])
            lineNumerStackView.addArrangedSubview(hstack)
        }
    }

    private func getLineClusters(basedOn limit: Int, lines: [String]) -> [Int] {
        var result: [Int] = []
        for line in lines {
            let lineCount = calculateMaxLines(for: line)
            result.append(((result.last { $0 != 0 } ?? 0) + 1))
            if lineCount > 1 {
                result = result + Array(repeating: 0, count: lineCount - 1)
            }
        }
        return result
    }

    private func calculateMaxLines(for text: String) -> Int {
        let maxSize = CGSize(width: UIScreen.main.bounds.width - Constants.lineNumberBoxWidth - 20, height: CGFloat(Float.infinity))
        let charSize = fontHeight
        let text = text as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: UIFont(name: "CourierNewPSMT", size: Constants.fontSize)!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }

    func onSelect(specialChar: String, updateCodeToCompile: Bool = true) {
        let range = textView.selectedRange
        let endPosition: UITextPosition = textView.selectedTextRange!.end
        self.textView.textStorage.replaceCharacters(in: range, with: specialChar)

        if updateCodeToCompile {
            self.codeToCompile = (self.codeToCompile as NSString).replacingCharacters(in: range, with: specialChar)
        }
        if let newPosition = self.textView.position(from: endPosition, offset: specialChar.count) {
                self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
        }
        if let value = self.autocompleteSymbols[specialChar] {
            let range = textView.selectedRange
            codeToCompile = (codeToCompile as NSString).replacingCharacters(in: range, with: value)
            self.textView.textStorage.replaceCharacters(in: range, with: value)
        }
        textViewDidChange(textView)
    }
}

extension PlaygroundView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewHeightConstraint?.constant = textView.contentSize.height
        setupLineNumbers(height: textView.contentSize.height)

        guard let range = textView.selectedTextRange else {
            return
        }

        onCodeChange?(textView.text)

        let cursorRect = textView.caretRect(for: range.start)
        let rectToMakeVisible = textView.convert(cursorRect, to: scrollView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollView.scrollRectToVisible(rectToMakeVisible, animated: false)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        autocompleteDropdownHostingController?.view.removeFromSuperview()
        autocompleteDropdownHostingController?.removeFromParent()
        autocompleteDropdownHostingController = nil
        let (tabs, lastLineTabs) = newTabs(textView: textView, range: range)
        if text == "\n" {
            onSelect(specialChar: "\n\(tabs)", updateCodeToCompile: false)
            let spacesForTabs = String(repeating: "  ", count: lastLineTabs.count + 1)
            codeToCompile = (codeToCompile as NSString).replacingCharacters(in: range, with: " \(spacesForTabs)")
            return false
        } else if codeToCompile.count >= range.upperBound, text != "" {
            codeToCompile = (codeToCompile as NSString).replacingCharacters(in: range, with: text)
            let (word, range) = findWordBetweenSpaces(using: range, in: codeToCompile)
            if !word.isEmpty && text != " " {
                autocomplete(phrase: word, range: range)
            }

            if let value = self.autocompleteSymbols[text] {
                let range = textView.selectedRange
                codeToCompile = (codeToCompile as NSString).replacingCharacters(in: range, with: value)
                self.textView.textStorage.replaceCharacters(in: range, with: value)
            }
        } else {
            codeToCompile = (codeToCompile as NSString).replacingCharacters(in: range, with: text)
        }
        if let endPosition = textView.selectedTextRange?.end,
            let textRange = textView.textRange(from: textView.beginningOfDocument, to: endPosition),
           let text = textView.text(in: textRange),
           text.suffix(2) == "__",
           text.components(separatedBy: "\n ")[text.components(separatedBy: "\n ").count - 2].starts(with: " # ") {
            let comment = text.components(separatedBy: "\n ")[text.components(separatedBy: "\n ").count - 2]
            let code = aiGenerated.first { comment.contains($0.comment.removingPercentEncoding ?? "") }?.code.randomElement()
            var newRange = NSRange(location: range.location - 1, length: 2)
            generateByAI(textView: textView, range: newRange, code: "\(code?.removingPercentEncoding ?? "")")
        }
        return true
    }

    private func newTabs(textView: UITextView, range: NSRange) -> (tabs: String, lastLineTabs: String) {
        var linesBefore: [String] = []
        textView.text.prefix(range.location).enumerateLines(invoking: { line, stop in
            linesBefore.append(line)
        })
        let lastLineTabs = linesBefore.last { $0.last == language.openingSymbol }?.prefix(while: { $0 == " " }) ?? ""
        let evenNumberTabs = lastLineTabs.count % 2 == 0 ? lastLineTabs : lastLineTabs.prefix(lastLineTabs.count - 1)
        let newTab = linesBefore.last { $0.last == language.openingSymbol } != nil ? "  " : ""
        return (tabs: "\(evenNumberTabs)\(newTab)", lastLineTabs: String(lastLineTabs))
    }

    private func generateByAI(textView: UITextView, range: NSRange, code: String) {
        guard let selectedRange = textView.selectedTextRange else { return }
        let endPosition: UITextPosition = selectedRange.end
        var rect = textView.caretRect(for: endPosition)
        rect = textView.convert(rect, to: self)
        let customView = GenerateWithAIDropdownView { [weak self] in
            guard let self = self else { return }
            let item = code
            self.autocompleteDropdownHostingController?.view.removeFromSuperview()
            self.autocompleteDropdownHostingController?.removeFromParent()

            self.textView.textStorage.replaceCharacters(in: range, with: item)
            self.codeToCompile = (self.codeToCompile as NSString).replacingCharacters(in: range, with: item)
            if let newPosition = self.textView.position(from: endPosition, offset: (item.count - (range.upperBound - range.lowerBound) + 1)) {
                self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
                self.textViewDidChange(self.textView)
            }
            self.justAutocompleted = true
        }

        autocompleteDropdownHostingController = UIHostingController(rootView: customView)
        autocompleteDropdownHostingController?.view?.backgroundColor = .CodeChallenge.background
        autocompleteDropdownHostingController?.view?.layer.cornerRadius = 10
        if let view = autocompleteDropdownHostingController?.view {
            self.bringSubviewToFront(view)
        }
        setupDropdownViewConstraints(rect: rect, matchesCount: 1)
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
}

// MARK: Autocomplete logic
extension PlaygroundView {
    private func autocomplete(phrase: String, range: NSRange) {
        guard let selectedRange = textView.selectedTextRange else { return }
        let endPosition: UITextPosition = selectedRange.end
        let matches = AutocompleteTermsHelper.getMatches(string: phrase, language: language.rawValue)
        let matchesWithoutPhrase = matches.filter { $0 != phrase }
        if !matchesWithoutPhrase.isEmpty {
            var rect = textView.caretRect(for: endPosition)
            rect = textView.convert(rect, to: self)

            let customView = AutocompleteDropdownView(options: matchesWithoutPhrase) { [weak self] item in
                guard let self = self else { return }
                self.autocompleteDropdownHostingController?.view.removeFromSuperview()
                self.autocompleteDropdownHostingController?.removeFromParent()

                self.textView.textStorage.replaceCharacters(in: range, with: item)
                self.codeToCompile = (self.codeToCompile as NSString).replacingCharacters(in: range, with: item)
                if let newPosition = self.textView.position(from: endPosition, offset: (item.count - (range.upperBound - range.lowerBound) + 1)) {
                    self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
                    self.textViewDidChange(self.textView)
                }
                self.justAutocompleted = true
            }

            autocompleteDropdownHostingController = UIHostingController(rootView: customView)
            autocompleteDropdownHostingController?.view?.backgroundColor = .CodeChallenge.background
            autocompleteDropdownHostingController?.view?.layer.cornerRadius = 10
            if let view = autocompleteDropdownHostingController?.view {
                self.bringSubviewToFront(view)
            }
            setupDropdownViewConstraints(rect: rect, matchesCount: matches.count)
        }
    }

    private func setupDropdownViewConstraints(rect: CGRect, matchesCount: Int) {
        guard let autocompleteDropdownHostingController = autocompleteDropdownHostingController,
              let view = autocompleteDropdownHostingController.view else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)

        let topInset = min(rect.origin.y + 21,
                           UIScreen.main.bounds.height - 21)
        let leadingInset = min(rect.origin.x,
                               UIScreen.main.bounds.width - Constants.autocompleteDropdownItemWidth)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor,
                                      constant: topInset),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                          constant: leadingInset),
            view.heightAnchor.constraint(equalToConstant: Constants.autocompleteDropdownItemHeight * CGFloat(matchesCount) + 16),
            view.widthAnchor.constraint(equalToConstant: Constants.autocompleteDropdownItemWidth)
        ])
    }
}
