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
        if store.state.list.favourites.isEmpty {
            VStack {
                Text("Inga favoriter sparade")
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
                VStack(spacing: 25) {
                    ForEach(store.state.list.favourites, id:\.self) { event in
                        ZStack(alignment: .topTrailing) {
                            RowView(event: event)
                            
                            Image(systemName: "heart.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.red)
                                .offset(x: -20, y: 30)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
                .background(
                    ListViewTopRectangle(),
                    alignment: .top
                )
                .background(Color.listBackground)
                .edgesIgnoringSafeArea(.bottom)
                .navigationTitle("Favoriter")
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        let event = Event(
            id: "1234",
            name: "The Other Favourites",
            subHeader: "",
            status: "Open",
            description: "The Other Favorites is the long time duo project of Carson McKee and Josh Turner. Perhaps best known for their performances on YouTube, which have garnered millions of views. The Other Favorites are now based out of Brooklyn, NY. Together, Turner and McKee bring their shared influences of folk, bluegrass and classic rock into a modern framework; one distinguished by incisive songwriting, virtuosic guitar work and tight two-part harmony.\n\nReina del Cid is a singer songwriter and leader of the eponymous folk rock band based in Los Angeles. Her song-a-week video series, Sunday Mornings with Reina del Cid, has amassed 40 million views on YouTube and collected a diverse following made up of everyone from jamheads to college students to white-haired intelligentsia. In 2011 she began collaborating with Toni Lindgren, who is the lead guitarist on all three of Del Cid’s albums, as well as a frequent and much beloved guest on the Sunday Morning videos. The two have adapted their sometimes hard-hitting rock ballads and catchy pop riffs into a special acoustic duo set.",
            ageLimit: "18 år",
            image: "https://debaser.se/img/10982.jpg",
            date: "2010-01-19",
            open: "Öppnar kl 18:30",
            room: "Bar Brooklyn",
            venue: "Strand",
            slug: nil,
            admission: "Fri entre",
            ticketUrl: nil
        )
        
        let model = EventViewModel(with: event)
        let listState = ListState(favourites: [])
        
        let store: Store<AppState, AppAction> = Store(
            initialState: AppState(
                list: listState,
                settings: SettingsState(),
                onboarding: OnboardingState()
            ),
            reducer: appReducer
        )
        
        ForEach(ColorScheme.allCases, id:\.self) {
            FavouritesView()
                .environmentObject(store)
                .preferredColorScheme($0)
        }
    }
}
