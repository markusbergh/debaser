//
//  AllEventView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import SwiftUI

struct AllEventView: View {
    var body: some View {
        NavigationView {
            VStack {
                ListView(type: .all)
                    .navigationTitle("Debaser")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AllEventView_Previews: PreviewProvider {
    static var previews: some View {
        AllEventView()
    }
}
