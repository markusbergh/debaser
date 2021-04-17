//
//  DebaserApp.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-12.
//

import SwiftUI

@main
struct DebaserApp: App {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true

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
