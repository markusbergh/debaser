//
//  ListAction.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import Foundation

enum ListAction {
    case getEventsRequest
    case getEventsComplete(events: [EventViewModel])
    case getEventsError(error: ServiceError?)
    case searchEvent(query: String)
    case getFavouritesRequest
    case getFavouritesComplete([EventViewModel])
    case getFavouritesError
    case toggleFavourite(EventViewModel)
    case toggleFavouriteComplete([EventViewModel])
    case toggleFavouriteError
    case hideTabBar
    case showTabBar
}
