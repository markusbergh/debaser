//
//  DebaserApp.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-12.
//

import SwiftUI

@main
struct DebaserApp: App {
    @AppStorage("darkMode") var isDarkMode: Bool = false

    @StateObject var viewRouter = ViewRouter()
    @StateObject var store = Store(initialState: AppState(), reducer: appReducer)
        
    var body: some Scene {
        WindowGroup {
            ContentView(viewRouter: viewRouter)
                .environmentObject(store)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
