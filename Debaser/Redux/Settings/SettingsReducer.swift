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
    var hideCancelled = CurrentValueSubject<Bool, Never>(false)
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
        saveUserDefaults(value: isOn, forKey: "darkMode")
        state.darkMode.send(isOn)
    case .getShowImages:
        let willShow = UserDefaults.standard.bool(forKey: "showImages")
        state.showImages.send(willShow)
    case .setShowImages(let willShow):
        saveUserDefaults(value: willShow, forKey: "showImages")
        state.showImages.send(willShow)
    case .getHideCancelled:
        let willHide = UserDefaults.standard.bool(forKey: "hideCancelled")
        state.hideCancelled.send(willHide)
    case .setHideCancelled(let willHide):
        saveUserDefaults(value: willHide, forKey: "hideCancelled")
        state.hideCancelled.send(willHide)
    }
    
    return state
}

// MARK: UserDefaults

private func saveUserDefaults(value: Any, forKey key: String) {
    UserDefaults.standard.setValue(value, forKey: key)
}
