//
//  ListAction.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-24.
//

import DebaserService

enum ListAction {
    case getEventsRequest
    case getEventsComplete(events: [Event])
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
