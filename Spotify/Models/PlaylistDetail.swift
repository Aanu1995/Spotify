//
//  PlaylistDetail.swift
//  Spotify
//
//  Created by user on 01/04/2021.
//

import Foundation

struct PlaylistDetailResponse: Codable {
    let id: String
    let name: String
    let images: [ImageModel]
    let description: String
    let externalURLs: [String: String]
    let tracks: PlaylistTrackResponse
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case images
        case description
        case externalURLs = "external_urls"
        case tracks
    }
    
    struct PlaylistTrackResponse: Codable {
        let items: [PlaylistItem]
        
        struct PlaylistItem: Codable {
            let track: AudioTrack
        }
    }
}
