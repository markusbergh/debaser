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
    var isFetching = CurrentValueSubject<Bool, Never>(false)
    var fetchError: String?
    var events: [EventViewModel] = []
}

// MARK: Reducer

func listReducer(state: inout ListState, action: ListAction) -> ListState {
    var state = state
    
    switch action {
    case .getEventsRequest:
        state.isFetching.send(true)
    case .getEventsError(let error):
        state.isFetching.send(false)
        state.fetchError = error?.description
    case .getEventsComplete(let events):
        state.isFetching.send(false)
        state.events = events
    }
    
    return state
}
