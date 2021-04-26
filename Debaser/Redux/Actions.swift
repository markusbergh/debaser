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
    case onboarding(OnboardingAction)
    case spotify(SpotifyAction)
}
