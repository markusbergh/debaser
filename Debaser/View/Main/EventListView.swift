//
//  EventListView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import SwiftUI

typealias AppStore = Store<AppState, AppAction>

struct EventListView: View {
    @EnvironmentObject var store: AppStore

    @Binding var isShowingTabBar: Bool
    @State private var totalPadding: CGFloat = 20
    
    var body: some View {
        NavigationView {
            VStack {               
                ListView(
                    headline: "Stockholm",
                    label: "Dagens konserter",
                    isShowingTabBar: $isShowingTabBar
                )
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // store.dispatch(.getEvents(EventService()))
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView(isShowingTabBar: .constant(true))
            .preferredColorScheme(.dark)
    }
}
