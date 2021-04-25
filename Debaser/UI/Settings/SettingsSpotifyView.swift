//
//  SettingsSpotifyView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import SwiftUI

struct SettingsSpotifyView: View {
    @State private var isConnected = false
    
    private var headerLabel: LocalizedStringKey {
        return "Settings.Spotify.Connection"
    }
    private var connectionLabel: LocalizedStringKey {
        return "Settings.Spotify.Connection.Label"
    }
    private var noConnectionLabel: LocalizedStringKey {
        return "Settings.Spotify.Connection.Off"
    }
    private var offLabel: LocalizedStringKey {
        return "Settings.Spotify.Off"
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text(headerLabel)) {
                    Toggle(offLabel, isOn: $isConnected)
                }
                .toggleStyle(SwitchToggleStyle(tint: .toggleTint))
                
                Section(
                    header: Text(connectionLabel),
                    footer: HStack {
                        Spacer()
                        Image("SpotifyLogotype")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 85)
                    }
                    .padding(.top, 5)
                    .frame(minWidth: 0, maxWidth: .infinity)
                ) {
                    Text(noConnectionLabel)
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
        ForEach(ColorScheme.allCases, id:\.self) {
            SettingsSpotifyView()
                .preferredColorScheme($0)
        }
    }
}
