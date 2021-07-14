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
    case requestLoginError(SpotifyServiceError)
    case requestLoginComplete
    case requestLogout
    case requestLogoutComplete
    case requestSearchArtist(String)
    case requestSearchArtistError(SpotifyServiceError)
    case requestSearchArtistComplete(SpotifyResult)
}
