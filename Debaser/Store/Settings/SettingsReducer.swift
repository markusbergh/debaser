//
//  Reducer.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import Combine
import Foundation

// MARK: Initial state

class SettingsState: ObservableObject {
    @Published var showImages = true
    @Published var systemColorScheme = true
    @Published var darkMode = false
    @Published var hideCancelled = false
    @Published var spotifyConnection: [String: Any]?
    @Published var pushToSpotifySettings = false
}

// MARK: Reducer

func settingsReducer(state: inout SettingsState, action: SettingsAction) -> SettingsState {
    
    switch action {
    case .getOverrideColorScheme:
        let overrideColorScheme = UserDefaults.standard.object(forKey: "overrideColorScheme") as? Bool ?? true
        state.systemColorScheme = overrideColorScheme
    case .setOverrideColorScheme(let isOn):
        saveUserDefaults(value: isOn, forKey: "overrideColorScheme")
        state.systemColorScheme = isOn
    case .getDarkMode:
        let darkMode = UserDefaults.standard.object(forKey: "darkMode") as? Bool ?? false
        state.darkMode = darkMode
    case .setDarkMode(let isOn):
        saveUserDefaults(value: isOn, forKey: "darkMode")
        state.darkMode = isOn
    case .getShowImages:
        let willShow = UserDefaults.standard.object(forKey: "showImages") as? Bool ?? true
        state.showImages = willShow
    case .setShowImages(let willShow):
        saveUserDefaults(value: willShow, forKey: "showImages")
        state.showImages = willShow
    case .getHideCancelled:
        let willHide = UserDefaults.standard.bool(forKey: "hideCancelled")
        state.hideCancelled = willHide
    case .setHideCancelled(let willHide):
        saveUserDefaults(value: willHide, forKey: "hideCancelled")
        state.hideCancelled = willHide
    case .pushToSpotifySettings:
        state.pushToSpotifySettings = true
    case .resetPushToSpotifySettings:
        state.pushToSpotifySettings = false
    }
    
    return state
}

// MARK: UserDefaults

private func saveUserDefaults(value: Any, forKey key: String) {
    UserDefaults.standard.setValue(value, forKey: key)
}
