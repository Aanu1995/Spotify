//
//  NewRelease.swift
//  Spotify
//
//  Created by user on 29/03/2021.
//

import Foundation

struct NewRelease: Codable {
    let albums: AlbumResponse
    
    struct AlbumResponse: Codable {
        let items: [Album]
    }
}

struct Album: Codable {
    let id: String
    let name: String
    let albumType: String
    let artists: [Artist]
    let availableMarkets: [String]
    let images: [ImageModel]
    let releaseDate: String
    let totalTracks: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case images
        case releaseDate = "release_date"
        case totalTracks = "total_tracks"
    }
}
