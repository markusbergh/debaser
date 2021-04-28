//
//  CarouselItem.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-28.
//

import SwiftUI

struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

class UIStateModel: ObservableObject {
    @Published var activeCard = 0
    @Published var screenDrag: Float = 0.0
}

struct SnapCarousel: View {
    var UIState: UIStateModel
    var spacing: CGFloat = 16
    var widthOfHiddenCards: CGFloat = 32
    var cardHeight: CGFloat = 200
    var items: [Card] = []
    
    @State private var transition: AnyTransition = .slide
    @State private var animation: Animation? = nil
    
    @State private var viewIsLoaded = false
    @State private var opacity: Double = 0

    var body: some View {
        Canvas {
            ZStack {
                GeometryReader {
                    Color.clear
                        .preference(
                            key: FramePreferenceKey.self,
                            value: $0.frame(in: .global)
                        )
                }
                .frame(width: 0, height: 0)
                
                // Needs to check (for now) when view has really loaded
                .onPreferenceChange(FramePreferenceKey.self) { frame in
                    let frameXPosition = Int(frame.origin.x)
                    
                    viewIsLoaded = frameXPosition > 0
                }

                Carousel(
                    numberOfItems: CGFloat(items.count),
                    spacing: spacing,
                    widthOfHiddenCards: widthOfHiddenCards
                ) {
                    ForEach(items, id: \.self.id) { item in
                        CarouselItem(
                            id: Int(item.id),
                            spacing: spacing,
                            widthOfHiddenCards: widthOfHiddenCards,
                            cardHeight: cardHeight
                        ) {
                            CarouselItemContent(event: item.event)
                        }
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
                        .background(Color.listRowBackground)
                        .cornerRadius(15)
                        .transition(transition)
                        .animation(animation)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 0.25)) {
                                opacity = 1.0
                            }
                        }
                        .onAnimationCompleted(for: opacity) {
                            if animation == nil {
                                animation = .spring()
                            }
                        }
                    }
                }
                .environmentObject(self.UIState)
            }
        }
        .frame(height: 200)
        .background(Color.clear)
    }
}

struct Carousel<Items : View> : View {
    let items: Items
    let numberOfItems: CGFloat
    let spacing: CGFloat
    let widthOfHiddenCards: CGFloat
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @GestureState var isDetectingLongPress = false
    
    @EnvironmentObject var UIState: UIStateModel
    
    @inlinable public init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        @ViewBuilder _ items: () -> Items
    ) {
        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards * 2) - (spacing * 2)
    }
    
    var body: some View {
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
        
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)
        
        var calcOffset = Float(activeOffset)
        
        if (calcOffset != Float(nextOffset)) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .highPriorityGesture(DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
            self.UIState.screenDrag = Float(currentState.translation.width)
        }.onEnded { value in
            self.UIState.screenDrag = 0
            
            if (value.translation.width < -50 && CGFloat(self.UIState.activeCard) < numberOfItems - 1) {
                self.UIState.activeCard = self.UIState.activeCard + 1
                
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
            
            if (value.translation.width > 50 && CGFloat(self.UIState.activeCard) > 0) {
                self.UIState.activeCard = self.UIState.activeCard - 1
                
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        })
    }
}

struct Canvas<Content: View> : View {
    @EnvironmentObject var UIState: UIStateModel

    let content: Content

    @inlinable init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .center
            )
    }
}
