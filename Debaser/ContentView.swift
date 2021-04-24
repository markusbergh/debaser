//
//  ContentView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-12.
//

import Combine
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var tabViewRouter: TabViewRouter

    @State var selectedTab: String = "music.note.house"
    @State var isShowingTabBar = false
    @State var isShowingOnboarding = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                
                let currentTab = tabViewRouter.currentTab
                
                switch currentTab {
                case .list:
                    EventListView(isShowingTabBar: $isShowingTabBar)
                case .favourites:
                    FavouritesView()
                case .settings:
                    SettingsView()
                }
                
                Spacer()
            }
            
            TabBar(selectedTab: $selectedTab)
                .environmentObject(tabViewRouter)
                .offset(y: isShowingTabBar ? 0 : 110)
                .animation(Animation.easeInOut(duration: 0.2))
        }
        .ignoresSafeArea()
        .onAppear {
            store.dispatch(withAction: .onboarding(.getOnboarding))
        }
        .onReceive(store.state.onboarding.seenOnboarding) { hasSeen in
            isShowingOnboarding = !hasSeen
        }
        .sheet(isPresented: $isShowingOnboarding) {
            OnboardingView()
                .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store: Store<AppState, AppAction> = Store(
            initialState: AppState(
                list: ListState(),
                settings: SettingsState(),
                onboarding: OnboardingState()
            ),
            reducer: appReducer
        )
        
        ContentView()
            .environmentObject(store)
            .environmentObject(TabViewRouter())
    }
}
