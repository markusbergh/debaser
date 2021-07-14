//
//  SettingsSpotifyView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import SwiftUI

struct SettingsSpotifyView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.spotifyService) var spotifyService

    @State private var willShowSpotifyLogin = false
    @State private var isConnectedToggle = false
    @State private var isConnected = false
    @State private var toggleLabel: LocalizedStringKey = "Settings.Spotify.Off"

    private var headerLabel: LocalizedStringKey {
        return "Settings.Spotify.Connection"
    }
    
    private var connectionLabel: LocalizedStringKey {
        return "Settings.Spotify.Connection.Label"
    }
    
    private var noConnectionLabel: LocalizedStringKey {
        return "Settings.Spotify.Connection.Off"
    }
    
    private var streamingControllerReceivedError: NotificationCenter.Publisher {
        return NotificationCenter.default.publisher(for: NSNotification.Name("spotifyStreamingControllerError"))
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text(headerLabel)) {
                    Toggle(isOn: $isConnectedToggle) {
                        Text(toggleLabel)
                            .foregroundColor(isConnected ? .green : .primary)
                    }
                    .onChange(of: isConnectedToggle) { isOn in
                        if isOn {
                            store.dispatch(action: .spotify(.requestLogin))
                        } else {
                            store.dispatch(action: .spotify(.requestLogout))
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .toggleTint))
                }
                
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
                    if !isConnected {
                        Text(noConnectionLabel)
                            .foregroundColor(.gray)
                    } else if let currentUser = spotifyService.currentUser {
                        Text(currentUser.displayName)
                    } else {
                        Text("")
                    }
                }
            }
            .background(
                SettingsViewTopRectangle(),
                alignment: .top
            )
            .background(
                Color.settingsBackground
                    .ignoresSafeArea()
            )
        }
        .onChange(of: store.state.spotify.isRequesting) { isRequesting in
            willShowSpotifyLogin = isRequesting
        }
        .onChange(of: store.state.spotify.isLoggedIn) { isLoggedIn in
            isConnected = isLoggedIn
            
            if isConnected && willShowSpotifyLogin {
                willShowSpotifyLogin = false
            } else if isConnected {
                toggleLabel = "Settings.Spotify.On"
            } else if !isConnected {
                toggleLabel = "Settings.Spotify.Off"
            }
        }
        .onChange(of: store.state.spotify.requestError) { error in
            guard let error = error else { return }
            
            switch error {
            case .premiumAccountRequired:
                willShowSpotifyLogin = false
                isConnected = false
                isConnectedToggle = false
            default:
                willShowSpotifyLogin = false
                isConnected = false
                isConnectedToggle = false
            }
        }
        .onAppear {
            if store.state.spotify.isLoggedIn == true {
                isConnected = true
                isConnectedToggle = true
                toggleLabel = "Settings.Spotify.On"
            }
        }
        .onReceive(streamingControllerReceivedError) { notification in
            handleDidReceiveSpotifyError(notification)
        }
        .sheet(isPresented: $willShowSpotifyLogin, onDismiss: onDismissSpotifyLoginSheet) {
            if let auth = spotifyService.auth {
                WebView(url: auth.spotifyWebAuthenticationURL()) {
                    // Maybe this can be checked somewhere else?
                    isConnected = spotifyService.userState == .active
                    
                    if isConnected {
                        toggleLabel = "Settings.Spotify.On"
                    } else {
                        store.dispatch(action: .spotify(.requestLoginError(.unknownError)))
                    }
                }
                .ignoresSafeArea()
            }
        }
        .navigationTitle("Spotify")
    }
    
    private func onDismissSpotifyLoginSheet() {
        if isConnected {
            toggleLabel = "Settings.Spotify.On"
        }
    }
    
    private func handleDidReceiveSpotifyError(_ notification: NotificationCenter.Publisher.Output) {
        guard let error = notification.object as? NSError else {
            store.dispatch(action: .spotify(.requestLoginError(.unknownError)))
            
            return
        }

        if error.code == 9 {
            store.dispatch(action: .spotify(.requestLoginError(.premiumAccountRequired)))
        }
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
