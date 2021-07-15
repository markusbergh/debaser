//
//  FavouriteRowView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-01.
//

import SwiftUI

struct FavouriteRowView: View {
    @EnvironmentObject var store: AppStore
    
    // MARK: Private
    
    @State private var isShowingDetailView = false
    @State private var titleHeight: CGFloat = 0.0
    
    private let topHeight: CGFloat = 120
    
    // MARK: Public
            
    let event: EventViewModel
    let totalHeight: CGFloat
    
    var overlayStrokeGradient: some View {
        return RoundedRectangle(cornerRadius: 15, style: .circular)
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
    }

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
                                FavouriteRowImageView(imageURL: event.image, height: topHeight)
                            }
                                                        
                            TitleView(
                                title: event.title,
                                fontSize: 27,
                                lineLimit: 3,
                                textColor: .white,
                                width: geometry.size.width * 0.65,
                                calculatedHeight: $titleHeight
                            )
                            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
                            .frame(width: geometry.size.width * 0.65, height: titleHeight)
                            .offset(x: 20, y: 20)
                        }
                        .frame(height: topHeight)
                        
                        FavouriteRowMetaView(
                            event: event,
                            topHeight: topHeight,
                            totalHeight: totalHeight
                        )
                    }
                    .frame(height: totalHeight)
                    .cornerRadius(15)
                    .background(
                        Rectangle()
                            .fill(Color.listRowBackground)
                            .cornerRadius(15)
                    )
                    .overlay(overlayStrokeGradient)
                }
            }
            .buttonStyle(FavouriteRowButtonStyle())
        }
        .accentColor(nil)
    }
}

// MARK: - Meta view

struct FavouriteRowMetaView: View {
    
    // MARK: Private
        
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
    
    private var eventVenue: String{
        return event.venue
    }
    
    private var bottomHeight: CGFloat {
        return totalHeight - topHeight
    }
    
    // MARK: Public
    
    let event: EventViewModel
    let topHeight: CGFloat
    let totalHeight: CGFloat
    
    var body: some View {
        HStack(spacing: 10) {
            Text(eventDate)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            Text(eventVenue)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 3)
        .frame(height: bottomHeight)
    }
}

// MARK: - Button style

struct FavouriteRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

struct FavouriteRowView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store
        let event = EventViewModel.mock
        
        FavouriteRowView(event: event, totalHeight: 170)
            .environmentObject(store)
    }
}
