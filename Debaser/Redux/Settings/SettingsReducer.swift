//
//  Reducer.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import Combine
import Foundation

// MARK: Initial state

struct SettingsState {
    var showImages = CurrentValueSubject<Bool, Never>(true)
    var darkMode = CurrentValueSubject<Bool, Never>(false)
    var spotifyConnection: [String: Any]?
}

// MARK: Reducer

func settingsReducer(state: inout SettingsState, action: SettingsAction) -> SettingsState {
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
