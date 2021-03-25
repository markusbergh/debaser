//
//  SettingsView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-25.
//

import SwiftUI

struct SettingsView: View {
    @State private var showImages = false
    
    var body: some View {
        Form {
            Toggle("Visa bilder", isOn: $showImages)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
