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
    
    /// User state
    @Published var isLoggedIn = false
    
    /// Data state
    @Published var isRequesting = false
    
    /// Error type
    @Published var requestError: SpotifyServiceError?
    
    /// Is set to `true` if a search for tracks is successful
    @Published var hasTracksForCurrentArtist = false
    
    /// Artist top trcks
    var topTracks: [SpotifyTrack]?
    
    init(topTracks: [SpotifyTrack]? = nil) {
        self.topTracks = topTracks
    }
}

// MARK: Reducer

func spotifyReducer(state: inout SpotifyState, action: SpotifyAction) -> SpotifyState {
    let state = state
    
    switch action {
    case .initialize:
        SpotifyService.shared.configure()
    case .requestLogin:
        state.isRequesting = true
        state.requestError = nil
    case .requestLoginError(let error):
        state.isRequesting = false
        state.requestError = error
        state.isLoggedIn = false
    case .requestLoginComplete:
        state.isRequesting = false
        state.isLoggedIn = true
    case .requestLogout:
        state.isRequesting = true
    case .requestLogoutComplete:
        state.isRequesting = false
        state.requestError = nil
        state.isLoggedIn = false
    case .requestSearchArtist:
        state.isRequesting = true
        state.hasTracksForCurrentArtist = false
    case .requestSearchArtistError(let error):
        state.isRequesting = false
        state.requestError = error
        state.hasTracksForCurrentArtist = false
    case .requestSearchArtistComplete(let result):
        state.isRequesting = false
        state.hasTracksForCurrentArtist = true
        state.topTracks = result.tracks
    }
    
    return state
}
