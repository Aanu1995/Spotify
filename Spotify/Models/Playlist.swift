//
//  Playlist.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import Foundation

struct Playlist: Codable{
    let id: String
    let name: String
    let description: String
    let externalURLs: [String: String]
    let images: [ImageModel]
    let owner: User
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case externalURLs = "external_urls"
        case images
        case owner
    }
    
    struct User: Codable {
        let id: String
        let displayName: String
        let externalURLs: [String: String]
        
        enum CodingKeys: String, CodingKey {
            case id
            case displayName = "display_name"
            case externalURLs = "external_urls"
        }
    }
}
