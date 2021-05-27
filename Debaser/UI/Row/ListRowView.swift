//
//  ListRowView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-08.
//

import SwiftUI

struct ListRowView: View {
    @EnvironmentObject var store: AppStore
    
    // MARK: Private
    
    @StateObject private var viewModel = ImageViewModel()
    @State private var isShowingDetailView = false
    
    private var isFavourite: Bool {
        return store.state.list.favourites.contains(where: { self.event.id == $0.id })
    }
    
    private var showImagesIfNeeded: Bool {
        return store.state.settings.showImages.value == true
    }
    
    // MARK: Public

    let event: EventViewModel
    let mediaHeight: CGFloat
    
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

                store.dispatch(action: .list(.hideTabBar))   
                dismissKeyboard()
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    ListRowImageView(mediaHeight: mediaHeight)
                        .environmentObject(viewModel)
                        .onAppear {
                            if showImagesIfNeeded {
                                viewModel.loadImage(with: event.image)
                            }
                        }
                        .modifier(
                            ListRowImageViewModifier(
                                isCancelled: event.isCancelled,
                                isPostponed: event.isPostponed,
                                maxHeight: mediaHeight
                            )
                        )
                        .modifier(
                            ListRowFavouriteViewModifier(
                                isFavourite: isFavourite
                            )
                        )

                    Text(event.title)
                        .font(Font.Variant.smaller(weight: .medium).font)
                        .foregroundColor(.primary)
                        .textCase(.uppercase)
                        .padding(.top, 10)
                    
                    Text(event.listDate)
                        .font(Font.Variant.micro(weight: .medium).font)
                        .foregroundColor(.gray)
                        .padding(.top, 2)

                    Text(event.venue)
                        .font(Font.Variant.micro(weight: .medium).font)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
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

// MARK: - View modifier

struct ListRowFavouriteViewModifier: ViewModifier {
    
    // MARK: Public
    
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

// MARK: - Button style

struct ListRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store
        let event = MockEventViewModel.event
        
        ListRowView(event: event)
            .preferredColorScheme(.dark)
            .environmentObject(store)
    }
}
