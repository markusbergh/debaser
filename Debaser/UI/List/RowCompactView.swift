//
//  RowCompactView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-08.
//

import SwiftUI

struct RowCompactView: View {
    @EnvironmentObject var store: AppStore
    @StateObject var viewModel = RowViewViewModel()

    @State private var isShowingDetailView = false

    private var title: String = ""
    private var date: String = ""
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let rawDate = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "d MMM"
        
        return dateFormatter.string(from: rawDate!)
    }
    
    var event: EventViewModel
    var mediaHeight: CGFloat
    var willShowInfoBar = false
    
    init(event: EventViewModel, mediaHeight: CGFloat = 100) {
        self.event = event
        self.mediaHeight = mediaHeight
        
        title = event.title
        date = event.date
    }
    
    var body: some View {
        NavigationLink(
            destination: DetailView(event: event),
            isActive: $isShowingDetailView
        ) {
            Button(action: {
                isShowingDetailView = true
                
                store.dispatch(withAction: .list(.hideTabBar))
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    RowCompactImageView(mediaHeight: mediaHeight)
                        .environmentObject(viewModel)
                        .onAppear {
                            if showImagesIfNeeded() {
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

                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .textCase(.uppercase)
                        .padding(.top, 10)
                    
                    Text(formattedDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.top, 2)

                    Text(event.venue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
            }
        }
    }
    
    func showImagesIfNeeded() -> Bool {
        return store.state.settings.showImages.value == true
    }
}

struct RowCompactImageView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var viewModel: RowViewViewModel
    @State private var opacity: Double = 0

    var mediaHeight: CGFloat?

    var body: some View {
        if showImagesIfNeeded() {
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
                .fill(Color.listNoImageBackground)
                .frame(height: mediaHeight)
                .cornerRadius(15)
        }
    }
    
    func showImagesIfNeeded() -> Bool {
        return store.state.settings.showImages.value == true
    }
}

struct RowCompactImageViewModifier: ViewModifier {
    var isCancelled = false
    var isPostponed = false
    var maxHeight: CGFloat
    
    func body(content: Content) -> some View {
        if isCancelled {
            return AnyView(
                ZStack(alignment: .center) {
                    content
                    Text("List.Event.Cancelled")
                        .font(.system(size: 19))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: maxHeight)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
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
                        .background(Color.black.opacity(0.5))
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
