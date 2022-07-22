//
//  NetworkImageViewModel.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation
import Combine
import SwiftUI

final class NetworkImageViewModel: ObservableObject {
    let store: Store
    @Published private (set) var image: UIImage?
    @Published private (set) var isLoading = false
    @Published private (set) var error: Error?

    init(
        url: String?,
        store: Store,
        placeholder: UIImage? = nil,
        showsPlaceholderInitially: Bool = false
    ) {
        if showsPlaceholderInitially {
            image = placeholder
        }

        self.store = store
        guard let url = url else {
            image = placeholder
            return
        }

        let publisher = store.services.imageService.loadImage(with: url)

        publisher
            .filter { !$0.isLoading && !$0.isPending }
            .map {
                switch $0 {
                case .success(let image): return image
                case .failure: return placeholder
                default: return nil
                }
            }
            .assign(to: &$image)

        publisher
            .map { $0.isLoading }
            .assign(to: &$isLoading)

        publisher
            .map { $0.error }
            .filter { $0 != nil }
            .assign(to: &$error)
    }
}
