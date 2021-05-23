//
//  FavouriteRowView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-01.
//

import SwiftUI

struct FavouriteRowView: View {
    @EnvironmentObject var store: AppStore
    
    @StateObject private var viewModel = ImageViewModel()
    @State private var isShowingDetailView = false
    @State private var titleHeight: CGFloat = 0.0
    
    private let topHeight: CGFloat = 120
    private var bottomHeight: CGFloat {
        return totalHeight - topHeight
    }
    
    private var cancelledLabel: String {
        return NSLocalizedString("List.Event.Cancelled", comment: "A cancelled event")
    }
    
    private var postponedLabel: String {
        return NSLocalizedString("List.Event.Postponed", comment: "A postponed event")
    }
    
    private var eventDate: String {
        if event.isPostponed {
            return postponedLabel
        } else if event.isCancelled {
            return cancelledLabel
        }
        
        return event.listDate
    }
    
    let event: EventViewModel
    let totalHeight: CGFloat

    var body: some View {
        NavigationLink(
            destination: DetailView(event: event),
            isActive: $isShowingDetailView
        ) {
            Button(action: {
                isShowingDetailView = true
                
                store.dispatch(action: .list(.hideTabBar))
            }) {
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(Color.listRowBackground)
                                .frame(minWidth: 0, maxWidth: .infinity)

                            if store.state.settings.showImages.value == true {
                                FavouriteRowImageView(image: viewModel.image, height: topHeight)
                            }
                                                        
                            TitleView(
                                title: event.title,
                                fontSize: 27,
                                lineLimit: 3,
                                textColor: .white,
                                calculatedHeight: $titleHeight
                            )
                            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
                            .frame(width: geometry.size.width * 0.65, height: titleHeight)
                            .offset(x: 20, y: 20)
                        }
                        .frame(height: topHeight)
                        
                        HStack(spacing: 10) {
                            Text(eventDate)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Spacer()

                            Text(event.venue)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 3)
                        .frame(height: bottomHeight)
                    }
                    .frame(height: totalHeight)
                    .cornerRadius(15)
                    .background(
                        Rectangle()
                            .fill(Color.listRowBackground)
                            .cornerRadius(15)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .circular)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [
                                            .listRowStrokeGradientStart,
                                            .listRowStrokeGradientEnd
                                        ]
                                    ),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            ).opacity(0.5)
                    )
                    .onAppear {
                        if store.state.settings.showImages.value == true {
                            viewModel.loadImage(with: event.image)
                        }
                    }
                }
            }
            .buttonStyle(FavouriteRowButtonStyle())
        }
        .accentColor(nil)
    }
}

struct FavouriteRowImageView: View {
    var image: UIImage
    var height: CGFloat
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: height)
            .clipped()
            .transition(
                .opacity.animation(.easeInOut(duration: 0.2))
            )
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    .listRowOverlayGradient.opacity(0.85),
                                    .listRowOverlayGradient.opacity(0)
                                ]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
    }
}

struct FavouriteRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

struct FavouriteRowView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store
        let event = MockEventViewModel.event
        
        FavouriteRowView(event: event, totalHeight: 170)
            .environmentObject(store)
    }
}
