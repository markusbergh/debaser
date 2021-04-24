//
//  OnboardingReducer.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import Combine
import Foundation

// MARK: Initial state

struct OnboardingState {
    var seenOnboarding = CurrentValueSubject<Bool, Never>(true)
}

// MARK: Reducer

func onboardingReducer(state: inout OnboardingState, action: OnboardingAction) -> OnboardingState {
    let state = state
    
    switch action {
    case .getOnboarding:
        let hasSeen = UserDefaults.standard.bool(forKey: "seenOnboarding")
        state.seenOnboarding.send(hasSeen)
    case .showOnboarding:
        state.seenOnboarding.send(false)
    }
    
    return state
}
