//
//  User.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import Foundation

struct UserProfile: Codable {
    let id: String
    let country: String
    let displayName: String
    let email: String
    let externalURLs: [String: String]
    let product: String
    let images: [ImageModel]
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case email
        case country
        case externalURLs = "external_urls"
        case product
        case images
    }
}
