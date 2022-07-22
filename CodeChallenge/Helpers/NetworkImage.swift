//
//  NetworkImage.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation
import SwiftUI

struct NetworkImage: View {
    @ObservedObject var viewModel: NetworkImageViewModel
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
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
            }
            if viewModel.isLoading {
                loadingView
            }
        }
        .frame(width: size.width, height: size.height, alignment: .center)
        .clipped()
    }
}
