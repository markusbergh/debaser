//
//  DetailFavouriteButtonView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-25.
//

import SwiftUI

struct DetailFavouriteButtonView: View {
    @EnvironmentObject var store: AppStore
    
    @State private var isFavourite = false
    
    let event: EventViewModel

    var body: some View {
        Button(action: {
            withAnimation {
                isFavourite.toggle()
            }
            
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            
            store.dispatch(action: .list(.toggleFavourite(event)))
        }) {
            Image(systemName: isFavourite ? "heart.fill" : "heart" )
                .resizable()
                .frame(width: 30, height: 30)
                .transition(
                    .asymmetric(
                        insertion: transition(insertionFor: isFavourite),
                        removal: transition(removalFor: isFavourite)
                    )
                )
                .id("is_favourite_active_\(isFavourite)")
        }
        .frame(width: 60, height: 40)
        .foregroundColor(.red)
        .background(
            Capsule()
                .fill(Color.detailFavouriteRibbonBackground)
                .frame(width: 60, height: 110)
                .offset(x: 0, y: -25)
        )
        .offset(x: 0)
        .onAppear {
            let match = store.state.list.favourites.firstIndex(where: { event -> Bool in
                return self.event.id == event.id
            })
            
            if match != nil {
                isFavourite = true
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func transition(insertionFor favourite: Bool) -> AnyTransition {
        let duration: Double = 0.3
        let anim: Animation = .easeInOut(duration: duration)
        
        if !favourite {
            return .identity
        }

        return .scale(scale: 0).animation(anim).combined(
            with: .opacity.animation(anim)
        )
    }
    
    private func transition(removalFor favourite: Bool) -> AnyTransition {
        let duration: Double = 0.3
        let anim: Animation = .easeInOut(duration: duration)
        
        if !favourite {
            return .asymmetric(
                insertion: .opacity.animation(anim),
                removal: .opacity.animation(anim)
            )
        }
        
        return .scale.animation(anim)
    }
}

struct DetailFavouriteButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store
        let event = EventViewModel.mock

        DetailFavouriteButtonView(event: event)
            .environmentObject(store)
    }
}

