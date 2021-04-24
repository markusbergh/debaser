//
//  DebaserApp.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-12.
//

import SwiftUI

@main
struct DebaserApp: App {
    // Application state
    @StateObject var store: Store<AppState, AppAction> = Store(
        initialState: AppState(list: ListState(), settings: SettingsState()),
        reducer: appReducer
    )
    
    // Tab state
    @StateObject var tabViewRouter = TabViewRouter()
    
    // Theme
    @State private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(store.state.settings.darkMode) { value in
                    isDarkMode = value
                }
                .onAppear {
                    store.dispatch(
                        AppAction.settings(
                            SettingsAction.getDarkMode
                        )
                    )
                }
                .environmentObject(store)
                .environmentObject(tabViewRouter)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
