//
//  Reducer.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import Combine
import Foundation

// MARK: Initial state

class ListState: ObservableObject {
    @Published var isFetching = false
    @Published var fetchError: String?
    @Published var events: [EventViewModel]
    @Published var favourites: [EventViewModel]
    @Published var isShowingTabBar = true
    @Published var currentSearch = ""
    
    init(events: [EventViewModel] = [], favourites: [EventViewModel] = []) {
        self.events = events
        self.favourites = favourites
    }
}

// MARK: Reducer

func listReducer(state: inout ListState, action: ListAction) -> ListState {
    
    switch action {
    case .getEventsRequest:
        state.isFetching = true
    case .getEventsError(let error):
        state.isFetching = false
        state.fetchError = error?.description
    case .getEventsComplete(let events):
        state.isFetching = false
        state.events = events
    case .searchEvent(let query):
        state.currentSearch = query
    case .toggleFavouriteComplete(let events):
        state.isFetching = false
        state.favourites = events
    case .getFavouritesComplete(let events):
        state.favourites = events
    case .hideTabBar:
        state.isShowingTabBar = false
    case .showTabBar:
        state.isShowingTabBar = true
    default:
        break
    }
    
    return state
}
