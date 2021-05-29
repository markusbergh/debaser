//
//  Reducer.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-15.
//

import Combine
import Foundation

// MARK: Initial state

struct AppState {
    
    // MARK: Public
    
    var list: ListState
    var settings: SettingsState
    var onboarding: OnboardingState
    var spotify: SpotifyState
    
    init(list: ListState, settings: SettingsState, onboarding: OnboardingState, spotify: SpotifyState) {
        self.list = list
        self.settings = settings
        self.onboarding = onboarding
        self.spotify = spotify
    }
}

// MARK: Root reducer

typealias Reducer<State, Action> = (inout State, Action) -> State

func appReducer(state: inout AppState, action: AppAction) -> AppState {
    var state = state
    
    switch action {
    case .settings(let settingsAction):
        var newState = state.settings
        
        newState = settingsReducer(state: &newState,
                                   action: settingsAction)
        
        state.settings = newState
    case .list(let listAction):
        var newState = state.list
        
        newState = listReducer(state: &newState,
                               action: listAction)
        
        state.list = newState
        
    case .onboarding(let onboardingAction):
        var newState = state.onboarding
        
        newState = onboardingReducer(state: &newState,
                                     action: onboardingAction)
        
        state.onboarding = newState
    case .spotify(let spotifyAction):
        var newState = state.spotify
        
        newState = spotifyReducer(state: &newState,
                                  action: spotifyAction)
        
        state.spotify = newState
    }
    
    return state
}
