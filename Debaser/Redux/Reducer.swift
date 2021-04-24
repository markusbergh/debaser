//
//  Reducer.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-15.
//

import Combine
import Foundation

// MARK: Initial state

/// Main

struct AppState {
    var list: ListState
    var settings: SettingsState
    
    init(list: ListState, settings: SettingsState) {
        self.list = list
        self.settings = settings
    }
}

/// List

struct ListState {
    var seenOnboarding = CurrentValueSubject<Bool, Never>(true)

    // TODO: Make use of collection
    var events: [Event] = []
}

/// Settings

struct SettingsState {
    var showImages = CurrentValueSubject<Bool, Never>(true)
    var darkMode = CurrentValueSubject<Bool, Never>(false)
    var spotifyConnection: [String: Any]?
}

// MARK: Reducer

typealias Reducer<State, Action> = (inout State, Action) -> State

/// Main

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
    }
    
    return state
}

/// List

private func listReducer(state: inout ListState, action: ListAction) -> ListState {
    let state = state
    
    switch action {
    case .getSeenOnboarding:
        let hasSeen = UserDefaults.standard.bool(forKey: "seenOnboarding")
        state.seenOnboarding.send(hasSeen)
    case .showOnboarding:
        state.seenOnboarding.send(false)
    case .getAllEvents:
        // TODO: Update list here instead of in view model
        ()
    }
    
    return state
}

/// Settings

private func settingsReducer(state: inout SettingsState, action: SettingsAction) -> SettingsState {
    let state = state
    
    switch action {
    case .getDarkMode:
        let darkMode = UserDefaults.standard.bool(forKey: "darkMode")
        state.darkMode.send(darkMode)
    case .setDarkMode(let isOn):
        UserDefaults.standard.setValue(isOn, forKey: "darkMode")
        state.darkMode.send(isOn)
    case .getShowImages:
        let willShow = UserDefaults.standard.bool(forKey: "showImages")
        state.showImages.send(willShow)
    case .setShowImages(let willShow):
        state.showImages.send(willShow)
    }
    
    return state
}
