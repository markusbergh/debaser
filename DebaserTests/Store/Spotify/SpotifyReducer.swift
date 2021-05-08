//
//  SpotifyReducer.swift
//  DebaserTests
//
//  Created by Markus Bergh on 2021-05-02.
//

import XCTest
@testable import Debaser

class SpotifyReducerTests: XCTestCase {
    func testSpotifyInitial() {
        var initialState = SpotifyState()
        
        let newState = spotifyReducer(state: &initialState, action: .initialize)
        
        XCTAssert(newState === initialState)
    }
    
    func testSpotifyLoginError() {
        var initialState = SpotifyState()
        
        let newState = spotifyReducer(state: &initialState, action: .requestLoginError(.authError))
        
        XCTAssertEqual(newState.isRequesting, false)
        XCTAssertNotNil(newState.requestError)
    }
    
    func testSpotifyLoginSuccess() {
        var initialState = SpotifyState()
        
        let newState = spotifyReducer(state: &initialState, action: .requestLoginComplete)
        
        XCTAssertEqual(newState.isRequesting, false)
        XCTAssertEqual(newState.isLoggedIn, true)
    }
    
    func testSpotifyLogout() {
        var initialState = SpotifyState()
        
        let newState = spotifyReducer(state: &initialState, action: .requestLogout)
        
        XCTAssertEqual(newState.isLoggedIn, false)
    }
    
    func testSpotifySearchArtistSuccess() {
        // TODO: Mock service and write test
    }
    
    func testSpotifySearchArtistError() {
        var initialState = SpotifyState()
        
        let newState = spotifyReducer(state: &initialState, action: .requestSearchArtistError(.tracksNotFoundForArtist))
        
        XCTAssertNotNil(newState.requestError)
        XCTAssertEqual(newState.hasTracksForCurrentArtist, false)
    }
}
