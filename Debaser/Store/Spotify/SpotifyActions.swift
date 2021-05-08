//
//  SpotifyActions.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-26.
//

import Foundation

enum SpotifyAction: Equatable {
    case initialize
    case requestLogin
    case requestLoginComplete
    case requestLoginError(SpotifyServiceError)
    case requestLogout
    case requestSearchArtist(String)
    case requestSearchArtistError(SpotifyServiceError)
    case requestSearchArtistComplete(String)
}
