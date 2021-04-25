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
    var favourites: [EventViewModel] = []
    var isShowingTabBar = true
    
    init(favourites: [EventViewModel] = []) {
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
    case .toggleFavourite(let isFavourite, let event):
        if !isFavourite {
            let indexOf = state.favourites.firstIndex(where: { (item) -> Bool in
                item.id == event.id
            })
            
            if let matchingIndex = indexOf {
                state.favourites.remove(at: matchingIndex)
            }
        } else {
            state.favourites.append(event)
        }
    case .hideTabBar:
        state.isShowingTabBar = false
    case .showTabBar:
        state.isShowingTabBar = true
    default:
        ()
    }
    
    return state
}
