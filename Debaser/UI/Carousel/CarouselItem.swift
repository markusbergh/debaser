//
//  CarouselItem.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-28.
//

import SwiftUI

struct Card: Decodable, Hashable, Identifiable {
    var id: Int
    var event: EventViewModel
}

struct CarouselItem<Content: View>: View {
    @EnvironmentObject var UIState: UIStateModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    var id: Int
    var content: Content
    
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

struct CarouselItemContent: View {
    @EnvironmentObject var store: AppStore
    @StateObject var viewModel = ImageViewModel()
    
    @State private var isShowingDetailView = false
    @State private var opacity: Double = 0

    var event: EventViewModel
    
    var body: some View {
        NavigationLink(
            destination: DetailView(event: event),
            isActive: $isShowingDetailView
        ) {
            Button(action: {
                isShowingDetailView = true
                
                store.dispatch(withAction: .list(.hideTabBar))
                
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
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
                            .background(Color.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    GeometryReader { geometry -> AnyView in
                        let midX = geometry.frame(in: .local).midX
                        let midY = geometry.frame(in: .local).midY
                        
                        return AnyView(
                            Text(event.title)
                                .font(Font.Family.title.of(size: 27))
                                .foregroundColor(.white)
                                .lineLimit(3)
                                .frame(width: 250)
                                .position(x: midX, y: midY)
                                .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
                        )
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .accentColor(.clear)
    }
}
