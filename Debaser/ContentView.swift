//
//  ContentView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-12.
//

import SwiftUI

typealias AppStore = Store<AppState, AppAction>

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var tabViewRouter: TabViewRouter
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: Private

    @State private var selectedTab: String = "music.note.house"
    @State private var isShowingOnboarding = false
    @State private var isShowingActivityIndicator = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                
                let currentTab = tabViewRouter.currentTab
                
                switch currentTab {
                case .list:
                    EventListView()
                case .favourites:
                    FavouritesView()
                case .settings:
                    SettingsView()
                }
                
                Spacer()
            }
            
            TabBar(selectedTab: $selectedTab)
                .environmentObject(tabViewRouter)
                .offset(y: store.state.list.isShowingTabBar ? 0 : 110)
                .animation(Animation.easeInOut(duration: 0.2))
        }
        .onReceive(store.state.onboarding.seenOnboarding) { hasSeen in
            isShowingOnboarding = !hasSeen
        }
        .onReceive(store.state.list.isFetching, perform: { isFetching in
            isShowingActivityIndicator = isFetching
        })
        .onReceive(store.state.settings.pushToSpotifySettings) { _ in
            if store.state.settings.pushToSpotifySettings.value == true {
                tabViewRouter.currentTab = .settings
            }
        }
        .sheet(isPresented: $isShowingOnboarding) {
            presentOnboarding()
        }
        .overlay(
            ListProgressIndicatorView(
                isShowingActivityIndicator: isShowingActivityIndicator
            )
        )
        .ignoresSafeArea()
    }
}

extension ContentView {
    
    ///
    /// Presents onboarding
    ///
    /// - returns: A `OnboardingView` to present modally
    ///
    private func presentOnboarding() -> some View {
        return OnboardingView()
            .background(Color.onboardingBackground)
            .ignoresSafeArea()
            .preferredColorScheme(colorScheme)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store
        
        ContentView()
            .environmentObject(TabViewRouter())
            .environmentObject(store)
    }
}
