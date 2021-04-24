//
//  SettingsSpotifyView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import SwiftUI

struct SettingsSpotifyView: View {
    @State private var isConnected = false
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Anslutning")) {
                    Toggle("Ej ansluten", isOn: $isConnected)
                }
                .toggleStyle(SwitchToggleStyle(tint: .toggleTint))
                
                Section(
                    header: Text("Ansluten som:"),
                    footer: HStack {
                        Spacer()
                        Image("SpotifyLogotype")
                    }
                    .padding(.top, 5)
                    .frame(minWidth: 0, maxWidth: .infinity)
                ) {
                    Text("Ingen aktiv anslutning")
                        .foregroundColor(.gray)
                }
            }
            .background(
                SettingsViewTopRectangle(),
                alignment: .top
            )
        }
        .navigationTitle("Spotify")
    }
}

struct SettingsSpotifyView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSpotifyView()
    }
}
