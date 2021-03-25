//
//  ContentView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LatestEventView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Senaste")
                }
            
            AllEventView()
                .tabItem {
                    Image(systemName: "list.triangle")
                    Text("Alla")
                }
            
            FavouritesView()
                .tabItem {
                    Image(systemName: "star")
                    Text("Favoriter")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Inställningar")
                }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
