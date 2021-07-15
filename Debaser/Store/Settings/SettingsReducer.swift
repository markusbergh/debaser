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
    
    /// Set to `false` is events should not load images
    var showImages = CurrentValueSubject<Bool, Never>(true)
    
    /// Which color scheme the app should use
    var systemColorScheme = CurrentValueSubject<Bool, Never>(true)
    
    /// Dark mode
    var darkMode = CurrentValueSubject<Bool, Never>(false)
    
    /// Set to `true` if all cancelled events should be hidden
    var hideCancelled = CurrentValueSubject<Bool, Never>(false)
    
    /// Optional connection to Spotify
    var spotifyConnection: [String: Any]?
    
    /// Set to `true` if deep-linking from onboarding
    var pushToSpotifySettings = CurrentValueSubject<Bool, Never>(false)
}

// MARK: Reducer

func settingsReducer(state: inout SettingsState, action: SettingsAction) -> SettingsState {
    let state = state
    
    switch action {
    case .getOverrideColorScheme:
        let overrideColorScheme = UserDefaults.standard.object(forKey: "overrideColorScheme") as? Bool ?? true
        state.systemColorScheme.send(overrideColorScheme)
    case .setOverrideColorScheme(let isOn):
        saveUserDefaults(value: isOn, forKey: "overrideColorScheme")
        state.systemColorScheme.send(isOn)
    case .getDarkMode:
        let darkMode = UserDefaults.standard.object(forKey: "darkMode") as? Bool ?? false
        state.darkMode.send(darkMode)
    case .setDarkMode(let isOn):
        saveUserDefaults(value: isOn, forKey: "darkMode")
        state.darkMode.send(isOn)
    case .getShowImages:
        let willShow = UserDefaults.standard.object(forKey: "showImages") as? Bool ?? true
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
    case .pushToSpotifySettings:
        state.pushToSpotifySettings.send(true)
    }
    
    return state
}

// MARK: UserDefaults

private func saveUserDefaults(value: Any, forKey key: String) {
    UserDefaults.standard.setValue(value, forKey: key)
}
