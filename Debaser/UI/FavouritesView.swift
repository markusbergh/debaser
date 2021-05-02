//
//  FavouritesView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import SwiftUI

struct FavouritesView: View {
    @EnvironmentObject var store: AppStore
    
    private var emptyLabel: LocalizedStringKey {
        return "Favourites.Empty"
    }
    
    private var titleLabel: LocalizedStringKey {
        return "Favourites"
    }

    var body: some View {
        if store.state.list.favourites.isEmpty {
            VStack {
                Text(emptyLabel)
                    .font(.system(size: 19))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ListViewTopRectangle(),
                alignment: .top
            )
            .background(Color.listBackground)
        } else {
            NavigationView {
                ScrollView {
                    VStack(spacing: 25) {
                        ForEach(store.state.list.favourites, id:\.self) { event in
                            ZStack(alignment: .topTrailing) {
                                RowView(event: event)

                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 35, height: 35)
                                    .overlay(
                                        Image(systemName: "heart.fill")
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(.red)
                                    )
                                    .offset(x: -20, y: 20)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .navigationTitle(titleLabel)
                }
                .padding(.top, 0.5)
                .background(
                    ListViewTopRectangle(),
                    alignment: .top
                )
                .background(
                    Color.listBackground
                        .edgesIgnoringSafeArea(.bottom)
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
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
            .preferredColorScheme(.dark)
    }
}
