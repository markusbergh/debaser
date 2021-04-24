//
//  Actions.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-15.
//

import Foundation

enum AppAction {
    case list(ListAction)
    case settings(SettingsAction)
}

enum ListAction {
    case getSeenOnboarding
    case showOnboarding
    case getAllEvents
}

enum SettingsAction {
    case getDarkMode
    case setDarkMode(Bool)
    case getShowImages
    case setShowImages(Bool)
}
