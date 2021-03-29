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
    let name: String
    let album_type: String
    let artists: [Artist]
    let available_market: [String]
    let images: [ImageModel]
    let release_date: String
    let total_tracks: Int
}
