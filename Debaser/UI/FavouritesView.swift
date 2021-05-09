//
//  FavouritesView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import SwiftUI

struct FavouritesView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationView {
            FavouriteListView()
        }
        .overlay(
            store.state.list.favourites.isEmpty ?
                AnyView(
                    FavouriteEmptyView()
                )
            : AnyView(EmptyView())
        )
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        let event = MockEventViewModel.event
        
        let listState = ListState(favourites: [event])
        let emptyListStae = ListState(favourites: [])
        
        FavouritesView()
            .environmentObject(
                Store(
                    initialState: AppState(
                        list: listState,
                        settings: SettingsState(),
                        onboarding: OnboardingState(),
                        spotify: SpotifyState()
                    ),
                    reducer: appReducer
                )
            )
        
        FavouritesView()
            .environmentObject(
                Store(
                    initialState: AppState(
                        list: emptyListStae,
                        settings: SettingsState(),
                        onboarding: OnboardingState(),
                        spotify: SpotifyState()
                    ),
                    reducer: appReducer
                )
            )
    }
}
