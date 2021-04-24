//
//  Reducer.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import Combine
import Foundation

// MARK: Initial state

struct ListState {
    var fetchError: String?
    var events: [EventViewModel] = []
}

// MARK: Reducer

func listReducer(state: inout ListState, action: ListAction) -> ListState {
    var state = state
    
    switch action {
    case .getEventsError(let error):
        state.fetchError = error?.description
    case .getEventsComplete(let events):
        state.events = events
    default:
        break
    }
    
    return state
}
