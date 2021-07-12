//
//  SpotifyTrack.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-07-12.
//

import Foundation

struct SpotifyResult: Equatable, Codable {
    let tracks: [SpotifyTrack]
}

struct SpotifyTrack: Equatable, Codable {
    let name: String
    let uri: String
    let album: SpotifyAlbum
    let artists: [SpotifyArtist]
}

struct SpotifyArtist: Equatable, Codable {
    let name: String
}

struct SpotifyAlbum: Equatable, Codable {
    let name: String
    let releaseDate: String
    let images: [SpotifyAlbumCover]
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case images
        case releaseDate = "release_date"
        case uri
    }
}

struct SpotifyAlbumCover: Equatable, Codable {
    let width: Int
    let height: Int
    let url: String
}
