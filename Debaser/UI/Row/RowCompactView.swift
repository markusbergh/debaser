//
//  RowCompactView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-08.
//

import SwiftUI

struct RowCompactView: View {
    @EnvironmentObject var store: AppStore
    @StateObject var viewModel = ImageViewModel()

    @State private var isShowingDetailView = false
    
    private var isFavourite: Bool {
        return store.state.list.favourites.contains(where: { self.event.id == $0.id })
    }
    
    private var showImagesIfNeeded: Bool {
        return store.state.settings.showImages.value == true
    }

    var event: EventViewModel
    var mediaHeight: CGFloat
    
    init(event: EventViewModel, mediaHeight: CGFloat = 100) {
        self.event = event
        self.mediaHeight = mediaHeight
    }
        
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
                VStack(alignment: .leading, spacing: 0) {
                    RowCompactImageView(mediaHeight: mediaHeight)
                        .environmentObject(viewModel)
                        .onAppear {
                            if showImagesIfNeeded {
                                viewModel.loadImage(with: event.image)
                            }
                        }
                        .modifier(
                            RowCompactImageViewModifier(
                                isCancelled: event.isCancelled,
                                isPostponed: event.isPostponed,
                                maxHeight: mediaHeight
                            )
                        )
                        .modifier(
                            RowCompactFavouriteViewModifier(
                                isFavourite: isFavourite
                            )
                        )

                    Text(event.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .textCase(.uppercase)
                        .padding(.top, 10)
                    
                    Text(event.listDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.top, 2)

                    Text(event.venue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .accentColor(.clear)
    }
}

struct RowCompactImageView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var viewModel: ImageViewModel

    @State private var opacity: Double = 0
    
    private var showImagesIfNeeded: Bool {
        return store.state.settings.showImages.value == true
    }

    var mediaHeight: CGFloat?

    var body: some View {
        if showImagesIfNeeded {
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFill()
                .frame(height: mediaHeight)
                .frame(minWidth: 0, maxWidth: .infinity)
                .cornerRadius(15)
                .opacity(opacity)
                .onReceive(viewModel.$isLoaded) { isLoaded in
                    if isLoaded {
                        withAnimation {
                            opacity = 1.0
                        }
                    }
                }
        } else {
            Rectangle()
                .fill(Color.listRowBackground)
                .frame(height: mediaHeight)
                .cornerRadius(15)
        }
    }
}

struct RowCompactFavouriteViewModifier: ViewModifier {
    var isFavourite = false
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            
            if isFavourite {
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.red)
                    )
                    .offset(x: -10, y: 10)
            }
        }
    }
}

struct RowCompactImageViewModifier: ViewModifier {
    @EnvironmentObject var store: AppStore

    var isCancelled = false
    var isPostponed = false
    
    var maxHeight: CGFloat
    
    func body(content: Content) -> some View {
        let opacity = store.state.settings.showImages.value ? 0.5 : 0.0
    
        if isCancelled {
            return AnyView(
                ZStack(alignment: .center) {
                    content
                    Text("List.Event.Cancelled")
                        .font(.system(size: 19))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: maxHeight)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(opacity))
                        .cornerRadius(15)
                }
            )
        } else if isPostponed {
            return AnyView(
                ZStack(alignment: .center) {
                    content
                    Text("List.Event.Postponed")
                        .font(.system(size: 19))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: maxHeight)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(opacity))
                        .cornerRadius(15)
                }
            )
        } else {
            return AnyView(content)
        }
    }
}

struct RowCompactView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store
        let event = MockEventViewModel.event
        
        RowCompactView(event: event)
            .preferredColorScheme(.dark)
            .environmentObject(store)
    }
}
