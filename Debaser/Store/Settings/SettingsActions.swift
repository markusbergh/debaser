//
//  SettingsAction.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import Foundation

enum SettingsAction {
    case getOverrideColorScheme
    case setOverrideColorScheme(Bool)
    case getDarkMode
    case setDarkMode(Bool)
    case getShowImages
    case setShowImages(Bool)
    case getHideCancelled
    case setHideCancelled(Bool)
    case pushToSpotifySettings
    case resetPushToSpotifySettings
}
