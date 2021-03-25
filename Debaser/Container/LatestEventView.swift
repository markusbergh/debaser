//
//  LatestEventView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import SwiftUI

struct LatestEventView: View {
    @State var selectedDate: SelectedDay = .today
    
    var body: some View {
        NavigationView {
            VStack {
                SelectDateView(selectedDate: $selectedDate)
                
                ListView(selectedDate: selectedDate, type: .latest)
                    .navigationTitle("Debaser")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }    
}

struct LatestEventView_Previews: PreviewProvider {
    static var previews: some View {
        LatestEventView()
    }
}
