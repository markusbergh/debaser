//
//  OnboardingReducer.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import Combine
import Foundation

// MARK: Initial state

class OnboardingState: ObservableObject, Equatable {
    @Published var seenOnboarding = true
    
    static func == (lhs: OnboardingState, rhs: OnboardingState) -> Bool {
        return lhs.seenOnboarding == rhs.seenOnboarding
    }
}

// MARK: Reducer

func onboardingReducer(state: inout OnboardingState, action: OnboardingAction) -> OnboardingState {
    
    switch action {
    case .getOnboarding:
        let hasSeen = UserDefaults.standard.bool(forKey: "seenOnboarding")
        state.seenOnboarding = hasSeen
    case .showOnboarding:
        state.seenOnboarding = false
    }
    
    return state
}
