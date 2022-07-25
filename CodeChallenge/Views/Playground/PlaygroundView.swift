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
        static let autocompleteDropdownItemHeight: CGFloat = 20
        static let autocompleteDropdownItemWidth: CGFloat = 200
        static let lineNumberBoxWidth: CGFloat = 40
        static let scrollViewTopInset: CGFloat = 100
        static let lineHeight: CGFloat = 14.5
        static let fontSize: CGFloat = 14.0
    }
    private let textView: UITextView = {
        let textStorage = CodeAttributedString()
        textStorage.language = "python"
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: UIScreen.main.bounds.size)
        layoutManager.addTextContainer(textContainer)

        let textView = UITextView(frame: .zero, textContainer: textContainer)
//        textView.font = .systemFont(ofSize: Constants.fontSize)
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.text =
        """
        @requires_authorization
        def somefunc(param1='', param2=0):
            r'''A docstring'''
            if param1 > param2: # interesting
                print 'Gre\'ater'
            return (param2 - param1 + 1 + 0b10l) or None

        class SomeClass:
            pass

        >>> message = '''interpreter
        ... prompt'''
        """
        return textView
    }()

    private var textViewHeightConstraint: NSLayoutConstraint?
    private var autocompleteDropdownHostingController: UIViewController?
    private var codeToCompile: String = ""

    private let lineNumerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.backgroundColor = .clear
        return stackView
    }()

    private let scrollView: UIScrollView = {
        return UIScrollView()
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        setupViews()
        codeToCompile = textView.text
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        textViewHeightConstraint?.constant = textView.contentSize.height
        print("MM", textView.contentSize.height)
        setupLineNumbers(height: textView.contentSize.height)
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
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            hStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            lineNumerStackView.widthAnchor.constraint(equalToConstant: Constants.lineNumberBoxWidth),
            justView.heightAnchor.constraint(equalToConstant: Constants.lineNumberBoxWidth),
            textView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - Constants.lineNumberBoxWidth)
        ])

        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: Constants.lineNumberBoxWidth)
        textViewHeightConstraint?.isActive = true
        textView.delegate = self

        lineNumerStackView.addArrangedSubview(justView)
    }

    private func setupLineNumbers(height: CGFloat) {
        lineNumerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let endIndex = Int(ceil(height/(textView.font?.lineHeight ?? Constants.lineHeight)))
        for i in (1...endIndex) {
            let label = UILabel()
            label.font = textView.font
            label.text = "\(i)"
            label.textColor = .white
            lineNumerStackView.addArrangedSubview(label)
        }
    }
}

extension PlaygroundView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewHeightConstraint?.constant = textView.contentSize.height
        setupLineNumbers(height: textView.contentSize.height)

        guard let range = textView.selectedTextRange else {
            return
        }

        let cursorRect = textView.caretRect(for: range.start)
        print("GM", cursorRect)
        let rectToMakeVisible = textView.convert(cursorRect, to: scrollView)
        DispatchQueue.main.async {
            self.scrollView.scrollRectToVisible(rectToMakeVisible, animated: false)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        autocompleteDropdownHostingController?.view.removeFromSuperview()
        autocompleteDropdownHostingController?.removeFromParent()
        autocompleteDropdownHostingController = nil
        if text == "\n" {
            codeToCompile = codeToCompile + " "
        } else if codeToCompile.count >= range.upperBound {
            codeToCompile = (codeToCompile as NSString).replacingCharacters(in: range, with: text)
            let (word, range) = findWordBetweenSpaces(using: range, in: codeToCompile)
            if !word.isEmpty {
                autocomplete(phrase: word, range: range)
            }
        } else {
            codeToCompile = codeToCompile + text
        }
        print("TT_", codeToCompile)
        return true
    }

    private func findWordBetweenSpaces(using range: NSRange, in text: String) -> (String, NSRange) {
        print(range.lowerBound, range.upperBound)
        let prefix = (text.prefix(range.lowerBound).lastIndex { $0 == " " })?.utf16Offset(in: text) ?? 0
        let suffix: Int
        if text.count - range.upperBound > 0 {
            suffix = (text.suffix(text.count - range.upperBound).firstIndex { $0 == " " })?
                .utf16Offset(in: text) ?? text.count
        } else {
            suffix = text.count
        }
        let range = String.Index(utf16Offset: min(prefix + 1, text.count), in: text)..<String.Index(utf16Offset: suffix, in: text)
        print(String(text[range]))
        return (String(text[range]), NSRange(range, in: text))
    }
}

// MARK: Autocomplete logic
extension PlaygroundView {
    private func autocomplete(phrase: String, range: NSRange) {
        guard let selectedRange = textView.selectedTextRange else { return }
        let endPosition: UITextPosition = selectedRange.end
        let matches = AutocompleteTermsHelper.getMatches(string: phrase)
        if !matches.isEmpty {
            var rect = textView.caretRect(for: endPosition)
            rect = textView.convert(rect, to: self)

            let customView = AutocompleteDropdownView(options: matches) { [weak self] item in
                guard let self = self else { return }
                print("Selected item: \(item)")
                self.autocompleteDropdownHostingController?.view.removeFromSuperview()
                self.autocompleteDropdownHostingController?.removeFromParent()

                self.textView.textStorage.replaceCharacters(in: range, with: item)
                self.codeToCompile = (self.codeToCompile as NSString).replacingCharacters(in: range, with: item)
                if let newPosition = self.textView.position(from: endPosition, offset: (item.count - (range.upperBound - range.lowerBound) + 1)) {
                    print("TT_position", newPosition)
                    self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
                }
                print("TT_", self.codeToCompile)
            }

            autocompleteDropdownHostingController = UIHostingController(rootView: customView)
            setupDropdownViewConstraints(rect: rect, matchesCount: matches.count)
        }
    }

    private func setupDropdownViewConstraints(rect: CGRect, matchesCount: Int) {
        guard let autocompleteDropdownHostingController = autocompleteDropdownHostingController,
              let view = autocompleteDropdownHostingController.view else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)

        let topInset = min(rect.origin.y + Constants.lineHeight,
                           UIScreen.main.bounds.height - Constants.lineHeight)
        let leadingInset = min(rect.origin.x,
                               UIScreen.main.bounds.width - Constants.autocompleteDropdownItemWidth)

        print(topInset)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor,
                                      constant: topInset),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                          constant: leadingInset),
            view.heightAnchor.constraint(equalToConstant: Constants.autocompleteDropdownItemHeight * CGFloat(matchesCount)),
            view.widthAnchor.constraint(equalToConstant: Constants.autocompleteDropdownItemWidth)
        ])
    }
}
