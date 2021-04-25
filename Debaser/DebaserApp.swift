//
//  DebaserApp.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-12.
//

import SwiftUI

@main
struct DebaserApp: App {
    @StateObject var store: Store<AppState, AppAction> = Store(
        initialState: AppState(
            list: ListState(),
            settings: SettingsState(),
            onboarding: OnboardingState()
        ),
        reducer: appReducer,
        middlewares: [
            listMiddleware(service: EventService())
        ]
    )
    
    @StateObject var tabViewRouter = TabViewRouter()
    @State private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(store.state.settings.darkMode) { value in
                    isDarkMode = value
                }
                .onAppear {
                    store.dispatch(withAction: .settings(.getDarkMode))
                    store.dispatch(withAction: .settings(.getHideCancelled))
                    store.dispatch(withAction: .settings(.getShowImages))
                }
                .environmentObject(store)
                .environmentObject(tabViewRouter)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
