//
//  AudioTrack.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import Foundation

struct AudioTrack : Codable {
    let id: String
    let name: String
    let album: Album?
    let artists: [Artist]
    let availableMarkets: [String]
    let discNumber: Int
    let durationInMilliseconds: Int
    let explicit: Bool
    let externalURLs: [String: String]
    let previewURL: String?
    let href: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case album
        case artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationInMilliseconds = "duration_ms"
        case explicit
        case externalURLs = "external_urls"
        case previewURL = "preview_url"
        case href
    }
}
