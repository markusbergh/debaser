//
//  SpotifyMiddleware.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-06-10.
//
import Foundation

import Combine
import Foundation

func spotifyMiddleware(service: SpotifyService = SpotifyService.shared) -> Middleware<AppState, AppAction> {
    return { state, action in
        switch action {
        
        /// Handles logout
        case .spotify(.requestLogout):
            if service.userState == .inactive {
                return Empty().eraseToAnyPublisher()
            }
            
            // Logs out user
            service.logout()
            
            let notificationName = Notification.Name(rawValue: SpotifyNotification.userLoggedOut.rawValue)
            
            // Subscribes to service notifier
            return NotificationCenter.default.publisher(for: notificationName)
                .map { _ in
                    return AppAction.spotify(.requestLogoutComplete)
                }
                .eraseToAnyPublisher()
            
        /// Handles a search for artist tracks
        case .spotify(.requestSearchArtist(let query)):
            
            return service.searchTrackForEventArtist(query: query)
                .map { AppAction.spotify(.requestSearchArtistComplete) }
                .catch { (error: SpotifyServiceError) -> Just<AppAction> in
                    Just(AppAction.spotify(.requestSearchArtistError(error)))
                }
                .eraseToAnyPublisher()
            
        default:
            return Empty().eraseToAnyPublisher()
        }
    }
}
