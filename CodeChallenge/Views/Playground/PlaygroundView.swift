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

        let textContainer = NSTextContainer(size: .init(
            width: .screenWidth - Constants.lineNumberBoxWidth - 10,
            height: .screenHeight - 260
        ))
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

    private var textViewHeightConstraint: NSLayoutConstraint?
    private var autocompleteDropdownHostingController: UIViewController?
    private var scrollViewBottomConstraint: NSLayoutConstraint?
    private var justAutocompleted: Bool = false
    private var fontHeight: CGFloat = UIFont(name: "CourierNewPSMT", size: Constants.fontSize)?.lineHeight ?? 0
    let vm: PlaygroundViewModel?

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

    init(vm: PlaygroundViewModel) {
        self.vm = vm
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reset(newCode: String) {
        vm?.set(code: newCode)
    }

    func onSelect(specialCharacter: String) {
        vm?.onSelect(specialCharacter: specialCharacter, range: textView.selectedRange)
    }

    func commonInit() {
        (self.textView.textStorage as? CodeAttributedString)?.language = vm?.language.rawValue
        vm?.onUpdate = { [weak self] updateType in
            switch updateType {
            case let .highlight(range, color):
                self?.textView.textStorage.addAttributes([.backgroundColor: color], range: range)
            case .codeChange(let code):
                self?.textView.text = code
            case .languageUpdate(let language):
                (self?.textView.textStorage as? CodeAttributedString)?.language = language.rawValue
            case .updateTextView:
                if let textView = self?.textView {
                    self?.textViewDidChange(textView)
                }
            case .updateCharactersInRange(let range, let text):
                guard let textView = self?.textView else { return }
                textView.textStorage.replaceCharacters(in: range, with: text)
            case .updateTextViewCursor(let offset):
                guard let textView = self?.textView else { return }
                guard let endPosition: UITextPosition = textView.selectedTextRange?.end else { return }
                if let newPosition = textView.position(from: endPosition, offset: offset) {
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                }
            case .workMatchesRetrieved(let matches, let range):
                guard let textView = self?.textView, let end = textView.selectedTextRange?.end else { return }
                var rect = textView.caretRect(for: end)
                rect = textView.convert(rect, to: self)

                let customView = AutocompleteDropdownView(options: matches) { [weak self] item in
                    guard let self = self else { return }
                    self.autocompleteDropdownHostingController?.view.removeFromSuperview()
                    self.autocompleteDropdownHostingController?.removeFromParent()
                    self.vm?.autocomplete(with: item, range: range)
                    self.justAutocompleted = true
                }

                self?.autocompleteDropdownHostingController = UIHostingController(rootView: customView)
                self?.autocompleteDropdownHostingController?.view?.backgroundColor = .CodeChallenge.background
                self?.autocompleteDropdownHostingController?.view?.layer.cornerRadius = 10
                if let view = self?.autocompleteDropdownHostingController?.view {
                    self?.bringSubviewToFront(view)
                }
                self?.setupDropdownViewConstraints(rect: rect, matchesCount: matches.count)
            }
        }
        setupViews()

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

    private func drawAIGeneratedIfNeeded(height: CGFloat) {
        guard let stackView = (self.scrollView.subviews.first { ($0 as? UIStackView) != nil }) else { return }
        stackView.subviews.filter { $0 != textView && $0 != lineNumerStackView }.forEach { $0.removeFromSuperview() }

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
        for (index, i) in lineNumbers.enumerated() {
            if i != 0, vm?.showGenerateByAI(for: lines[i - 1]) == true {
                let y = CGFloat(index) * fontHeight
                let view = GenerateWithAIView {

                }
                let hostingController = UIHostingController(rootView: view)
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                hostingController.view.backgroundColor = .clear

                stackView.addSubview(hostingController.view)
                NSLayoutConstraint.activate([
                    hostingController.view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                    hostingController.view.topAnchor.constraint(equalTo: stackView.topAnchor, constant: y)
                ])
            }
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
}

extension PlaygroundView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewHeightConstraint?.constant = textView.contentSize.height
        setupLineNumbers(height: textView.contentSize.height)

        if let range = textView.selectedTextRange {
            let cursorRect = textView.caretRect(for: range.start)
            let rectToMakeVisible = textView.convert(cursorRect, to: scrollView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollView.scrollRectToVisible(rectToMakeVisible, animated: false)
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.vm?.update(codeToCompile: textView.text)
            self?.vm?.applyHighlightingIfNeeded(string: textView.text as NSString)
            self?.drawAIGeneratedIfNeeded(height: textView.contentSize.height)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        autocompleteDropdownHostingController?.view.removeFromSuperview()
        autocompleteDropdownHostingController?.removeFromParent()
        autocompleteDropdownHostingController = nil

        return vm?.proceed(with: text, in: range, textViewText: textView.text) == true
    }
}

// MARK: Autocomplete logic
extension PlaygroundView {
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
