//
//  EventListView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import SwiftUI

struct EventListView: View {
    @EnvironmentObject var store: AppStore
    
    // MARK: Private

    @State private var totalPadding: CGFloat = 20
    
    private var todayLabel: LocalizedStringKey {
        return "List.Today"
    }
    
    private let userDefaults = UserDefaults.standard
    
    var body: some View {
        NavigationView {
            VStack {
                ListView(
                    headline: "Stockholm",
                    label: todayLabel
                )
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // We might be search... and have an empty result
            if !store.state.list.currentSearch.isEmpty {
                return
            }
            
            // Did we have a previous update in the background?
            let decoder = JSONDecoder()
            
            if let data = userDefaults.data(forKey: "se.ejzi.LatestEvents"),
               let events = try? decoder.decode([EventViewModel].self, from: data) {
                store.dispatch(action: .list(.getEventsComplete(events: events)))
            } else if store.state.list.events.isEmpty {
                store.dispatch(action: .list(.getEventsRequest))
            }
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        let store = MockStore.store

        EventListView()
            .preferredColorScheme(.dark)
            .environmentObject(store)
    }
}
