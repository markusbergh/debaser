//
//  Reducer.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-15.
//

import Foundation

// MARK: Initial state

struct AppState {
    var events: [Event] = []
}

// MARK: Reducer

typealias Reducer<State, Action> = (inout State, Action) -> Void

func appReducer(state: inout AppState, action: AppAction) {
    switch action {
    case .getEvents:
        
        break
    }
}
