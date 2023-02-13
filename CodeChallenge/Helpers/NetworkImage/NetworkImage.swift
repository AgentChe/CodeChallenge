//
//  NetworkImage.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation
import SwiftUI
import UIKit
import Combine

struct NetworkImage: View {
    @ObservedObject var viewModel: NetworkImageViewModel
    var animated: Bool = true
    var size: CGSize = .zero
    var contentMode: ContentMode = .fill

    private func contentView(image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }

    private var loadingView: some View {
        ProgressView()
    }

    var body: some View {
        ZStack {
            if let image = viewModel.image {
                contentView(image: Image(uiImage: image))
                    .transition(.opacity.animation(.easeIn(duration: animated ? 0.1 : 0)))
            }
            if viewModel.isLoading {
                loadingView
            }
        }
        .frame(width: size.width, height: size.height, alignment: .center)
        .clipped()
    }
}

final class NetworkImageView: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: NetworkImageViewModel?

    func bind(to viewModel: NetworkImageViewModel) {
        cancellables = []
        self.viewModel = viewModel

        viewModel.$image
            .sink { [weak self] in
                self?.imageView.image = $0
            }
            .store(in: &cancellables)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }
}

extension NetworkImageView {
    func setupViews() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}
