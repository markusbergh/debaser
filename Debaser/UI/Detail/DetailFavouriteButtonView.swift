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
    
    var event: EventViewModel

    var body: some View {
        Button(action: {
            isFavourite.toggle()
            
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            
            store.dispatch(withAction: .list(.toggleFavourite(isFavourite, event)))
        }) {
            Image(systemName: isFavourite ? "heart.fill" : "heart" )
                .resizable()
                .frame(width: 30, height: 30)
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
    }
}

struct DetailFavouriteButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store
        let event = MockEventViewModel.event

        DetailFavouriteButtonView(event: event)
            .environmentObject(store)
    }
}

