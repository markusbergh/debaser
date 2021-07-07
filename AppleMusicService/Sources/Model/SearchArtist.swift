//
//  Song.swift
//  AppleMusicService
//
//  Created by Markus Bergh on 2021-07-06.
//

import Foundation

struct SearchArtistResponse: Codable {
    let results: SearchArtistResult
}

struct SearchArtistResult: Codable {
    let songs: SongData
}

struct SongData: Codable {
    let data: [Song]
}

struct Song: Codable {
    let attributes: SongAttributes
}

struct SongAttributes: Codable {
    let name: String
    let previews: [SongPreviews]
}

public struct SongPreviews: Codable {
    public let url: String
}
