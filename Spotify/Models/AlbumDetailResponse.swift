//
//  AlbumDetailResponse.swift
//  Spotify
//
//  Created by user on 01/04/2021.
//

import Foundation

struct AlbumDetailResponse: Codable {
    let id: String
    let name: String
    let albumType: String
    let artists: [Artist]
    let availableMarkets: [String]
    let externalURLs: [String: String]
    let images: [ImageModel]
    let tracks: TrackResponse
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case externalURLs = "external_urls"
        case images
        case tracks
    }
}

struct TrackResponse: Codable {
    let items: [AudioTrack]
}
