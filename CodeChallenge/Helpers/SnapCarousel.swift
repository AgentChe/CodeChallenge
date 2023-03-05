//
//  SnapCarousel.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 04/03/2023.
//

import Foundation
import SwiftUI

struct Carousel<Items : View> : View {
    let items: Items
    let numberOfItems: CGFloat //= 8
    let spacing: CGFloat //= 16
    let widthOfHiddenCards: CGFloat //= 32
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @Binding var screenDrag: Float
    @Binding var activeCard: Int
    
    @GestureState var isDetectingLongPress = false
    
    @inlinable public init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        screenDrag: Binding<Float>,
        activeCard: Binding<Int>,
        @ViewBuilder _ items: () -> Items
    ) {

        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self._screenDrag = screenDrag
        self._activeCard = activeCard
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2) //279
    }
    
    var body: some View {
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
        
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(activeCard) + 1)
        
        var calcOffset = Float(activeOffset)
        
        if (calcOffset != Float(nextOffset)) {
            calcOffset = Float(activeOffset) + Float(screenDrag)
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .gesture(DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
            //            self.UIState.screenDrag = Float(currentState.translation.width)
        }.onEnded { value in
            screenDrag = 0
            
            if (value.translation.width < -50 && CGFloat(activeCard) < numberOfItems - 1) {
                activeCard = activeCard + 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
            
            if (value.translation.width > 50 && CGFloat(activeCard) > 0) {
                activeCard = activeCard - 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        })
    }
}
