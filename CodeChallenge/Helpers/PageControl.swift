//
//  PageControl.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/03/2023.
//

import Foundation
import SwiftUI

struct PageControl : UIViewRepresentable {

    @Binding var currentPageIndex: Int
    var numberOfPages : Int = 0

    /// Create UIView object and configure the initial state
    /// - Returns: UIPageControl
    func makeUIView(context: Context) -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .CodeChallenge.dustyBlue
        pageControl.currentPageIndicatorTintColor = .CodeChallenge.blue1
        pageControl.numberOfPages = numberOfPages

        return pageControl
    }

    /// Update the state of UIKit view based on new info given from SwiftUI
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPageIndex
    }
}
