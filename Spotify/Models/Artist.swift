//
//  Artist.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let externalURLs: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case externalURLs = "external_urls"
    }
}
