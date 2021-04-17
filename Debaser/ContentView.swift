//
//  ContentView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-12.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab: String = "mic"
    @State var isShowingTabBar = false
    
    @StateObject var viewRouter: ViewRouter

    var body: some View {
        
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                
                let currentPage = viewRouter.currentPage
                
                switch currentPage {
                case .list:
                    EventListView(isShowingTabBar: $isShowingTabBar)
                case .news:
                    Text("News")
                case .favourites:
                    FavouritesView()
                case .settings:
                    SettingsView()
                }
                
                Spacer()
            }
            
            TabBar(selectedTab: $selectedTab)
                .environmentObject(viewRouter)
                .offset(y: isShowingTabBar ? 0 : 110)
                .animation(Animation.easeInOut(duration: 0.2))
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewRouter: ViewRouter())
    }
}
