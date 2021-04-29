//
//  SpotifyReducer.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-26.
//

import Combine
import Foundation

// MARK: Initial state
 
class SpotifyState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isRequesting = false
    @Published var requestError: SpotifyServiceError?
    @Published var hasTracksForCurrentArtist = false
}

// MARK: Reducer

func spotifyReducer(state: inout SpotifyState, action: SpotifyAction) -> SpotifyState {
    let state = state
    
    switch action {
    case .initialize:
        SpotifyService.shared.setupHelper()
    case .requestLogin:
        state.requestError = nil
        state.isRequesting = true
    case .requestLoginError(let error):
        state.requestError = error
        state.isRequesting = false
        state.isLoggedIn = false
    case .requestLoginComplete:
        state.isRequesting = false
        state.isLoggedIn = true
    case .requestLogout:
        if SpotifyService.shared.isLoggedIn {
            SpotifyService.shared.logout()
        }
        
        state.requestError = nil
        state.isLoggedIn = false
    case .requestSearchArtist(let artist):
        state.hasTracksForCurrentArtist = false
        
        // This should probably be handled in a middleware
        SpotifyService.shared.searchTrackForEventArtist(query: artist) {
            state.hasTracksForCurrentArtist = true
        }
    case .requestSearchArtistError(let error):
        state.requestError = error
        state.hasTracksForCurrentArtist = false
    case .requestSearchArtistComplete(_):
        ()
    }
    
    return state
}
