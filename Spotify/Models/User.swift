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
    let display_name: String
    let email: String
    let external_urls: [String: String]
    let product: String
    let images: [ImageModel]
}
