//
//  CarouselItem.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-28.
//

import SwiftUI

struct Card: Decodable, Hashable, Identifiable {
    let id: Int
    let event: EventViewModel
}

struct CarouselItemView<Content: View>: View {
    @EnvironmentObject var UIState: CarouselState
    
    // MARK: Public
    
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let id: Int
    let content: Content
    
    @inlinable public init(
        id: Int,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        cardHeight: CGFloat,
        @ViewBuilder _ content: () -> Content
    ) {
        self.content = content()
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards * 2) - (spacing * 2)
        self.cardHeight = cardHeight
        self.id = id
    }
    
    var body: some View {
        content
            .frame(
                width: cardWidth,
                height: id == UIState.activeCard ? cardHeight : cardHeight - 60,
                alignment: .center
            )
    }
}

// MARK: - Content

struct CarouselItemContent: View {
    @EnvironmentObject var store: AppStore
    @StateObject var viewModel = ImageViewModel()
    
    // MARK: Private
    
    @State private var isShowingDetailView = false
    @State private var opacity: Double = 0
    
    // MARK: Public

    var event: EventViewModel
    
    var body: some View {
        NavigationLink(
            destination: DetailView(event: event),
            isActive: $isShowingDetailView
        ) {
            Button(action: {
                isShowingDetailView = true
                
                store.dispatch(action: .list(.hideTabBar))                
                dismissKeyboard()
            }) {
                ZStack(alignment: .center) {
                    if store.state.settings.showImages.value == true {
                        Image(uiImage: viewModel.image)
                            .resizable()
                            .scaledToFill()
                            .opacity(opacity)
                            .onReceive(viewModel.$isLoaded) { isLoaded in
                                if isLoaded {
                                    withAnimation {
                                        opacity = 1.0
                                    }
                                }
                            }
                            .onAppear {
                                viewModel.loadImage(with: event.image)
                            }
                    } else {
                        Rectangle()
                            .fill(Color.listRowBackground)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    GeometryReader { geometry -> AnyView in
                        let midX = geometry.frame(in: .local).midX
                        let midY = geometry.frame(in: .local).midY
                        
                        return AnyView(
                            VStack(alignment: .leading, spacing: 0) {
                                Group {
                                    if event.isCancelled {
                                        Text("List.Event.Cancelled")
                                    } else if event.isPostponed {
                                        Text("List.Event.Postponed")
                                    }
                                }
                                .foregroundColor(.white)
                                .font(Font.Variant.tiny.font)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 8)
                                .background(Capsule().fill(Color.listRowBackground))
                                
                                Text(event.title)
                                    .font(Font.Family.title.of(size: 29))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
                            }
                            .frame(width: geometry.size.width * 0.6)
                            .position(x: midX, y: midY)
                        )
                    }
                }
            }
            .buttonStyle(ListRowButtonStyle())
        }
        .accentColor(nil)
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
