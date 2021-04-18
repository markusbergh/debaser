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

typealias Reducer<State, Action> = (inout State, Action) -> State

func appReducer(state: inout AppState, action: AppAction) -> AppState {
    let state = state
    
    switch action {
    case .getEvents(let service):
        break
    }
    
    return state
}
