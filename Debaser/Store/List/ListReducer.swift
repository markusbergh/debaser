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
    var events: [EventViewModel]
    var favourites: [EventViewModel]
    var isShowingTabBar = true
    var currentSearch = ""
    
    init(events: [EventViewModel] = [], favourites: [EventViewModel] = []) {
        self.events = events
        self.favourites = favourites
    }
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
    case .searchEvent(let query):
        state.currentSearch = query
    case .toggleFavourite:
        break
    case .toggleFavouriteComplete(let events):
        state.isFetching.send(false)
        state.favourites = events
    case .getFavouritesComplete(let events):
        state.favourites = events
    case .hideTabBar:
        state.isShowingTabBar = false
    case .showTabBar:
        state.isShowingTabBar = true
    default:
        ()
    }
    
    return state
}
