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
        NavigationView {
            GeometryReader { geometry in
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
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 10)
                    .padding(.horizontal, 15)
                    .navigationTitle(titleLabel)
                }
                .padding(.top, 0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ListViewTopRectangle(),
                    alignment: .top
                )
                .background(
                    Color.listBackground
                        .edgesIgnoringSafeArea(.bottom)
                )
            }
        }
        .overlay(
            store.state.list.favourites.isEmpty ?
                AnyView(
                    GeometryReader { geometry in
                        ZStack {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.75)
                                .opacity(0.05)
                                .offset(y: 10)
                            
                            Text(emptyLabel)
                                .font(.system(size: 17))
                                .fontWeight(.semibold)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                )
            : AnyView(EmptyView())
        )
        .navigationViewStyle(StackNavigationViewStyle())
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
