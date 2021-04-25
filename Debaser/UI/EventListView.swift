//
//  EventListView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import SwiftUI

struct EventListView: View {
    @EnvironmentObject var store: AppStore

    @State private var totalPadding: CGFloat = 20
    
    private var todayLabel: LocalizedStringKey {
        return "List.Today"
    }
    
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
            if store.state.list.events.isEmpty {
                store.dispatch(withAction: .list(.getEventsRequest))
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
