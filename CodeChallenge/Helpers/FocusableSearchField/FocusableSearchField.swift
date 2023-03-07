//
//  FocusableSearchField.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 02/02/2022.
//

import Foundation
import UIKit
import SwiftUI
import Combine

struct FocusableSearchField: UIViewRepresentable {
    @ObservedObject var viewModel: ViewModel
    let onReturn: () -> Void
    var placeholder: String = "What are you looking for?"

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UITextField {
        let field = SearchTextField()
        field.font = .systemFont(ofSize: 14)
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardType = .webSearch
        field.textColor = .white
        field.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        field.accessibilityTraits = .searchField
        let leftImageView = UIImageView(image: .init(named: "search_field_icon"))
        leftImageView.contentMode = .center
        field.leftView = leftImageView
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .CodeChallenge.gray2
        field.layer.cornerRadius = 20
        context.coordinator.bind(to: field, viewModel: .init())
        let buttonAppearance = UIButton.appearance(whenContainedInInstancesOf: [SearchTextField.self])
        buttonAppearance.setImage(.init(named: "search_field_clear_icon"), for: .normal)
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.bind(to: uiView, viewModel: viewModel)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        context.coordinator.onReturn = onReturn
    }
}

extension FocusableSearchField {
    final class ViewModel: ObservableObject {
        @Published var text: String = ""
        @Published var isFocused: Bool = false
        var isSearchEnabled: Bool {
            isFocused || !text.isEmpty
        }
    }
}

extension FocusableSearchField {
    final class Coordinator: NSObject, UITextFieldDelegate {
        var onReturn: (() -> Void)?
        private var viewModel: ViewModel?
        private var cancellables = Set<AnyCancellable>()

        func bind(to field: UITextField, viewModel: ViewModel) {
            cancellables = []
            field.delegate = self
            self.viewModel = viewModel

            viewModel.$text
                .sink { [weak field] in field?.text = $0 }
                .store(in: &cancellables)

            viewModel
                .$isFocused
                .receive(on: DispatchQueue.main)
                .sink { [weak field] in
                    if $0 {
                        if field?.window != nil && !(field?.isFirstResponder ?? true) {
                            field?.becomeFirstResponder()
                        }
                    } else {
                        field?.resignFirstResponder()
                    }
                }
                .store(in: &cancellables)

            field
                .publisher(for: .editingChanged)
                .sink { [weak self, weak field] _ in
                    self?.viewModel?.text = field?.text ?? ""
                }
                .store(in: &cancellables)

            field
                .publisher(for: .editingDidEndOnExit)
                .sink { [weak self] _ in
                    self?.onReturn?()
                }
                .store(in: &cancellables)
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            viewModel?.text = textField.text ?? ""
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            viewModel?.isFocused = false
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            viewModel?.isFocused = true
        }
    }
}

final class SearchTextField: UITextField {
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return .init(x: bounds.size.width - 48, y: 0, width: 48, height: 48)
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return .init(x: 0, y: 0, width: 48, height: 48)
    }
}

#if DEBUG
struct FocusableSearchField_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            FocusableSearchField(viewModel: .init()) {}
        }
    }
}
#endif
