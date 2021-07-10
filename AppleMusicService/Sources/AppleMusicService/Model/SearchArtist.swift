//
//  Song.swift
//  AppleMusicService
//
//  Created by Markus Bergh on 2021-07-06.
//

import Foundation

// MARK: Private

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

// MARK: Public

public struct SongAttributes: Codable {
    public let name: String
    public let albumName: String
    public let artwork: SongArtwork
    public let playParams: SongPlayParameters
    public let previews: [SongPreview]
}

public struct SongPlayParameters: Codable {
    public let id: String
    public let kind: String
}

public struct SongArtwork: Codable {
    public let url: String
}

public struct SongPreview: Codable {
    public let url: String
}
