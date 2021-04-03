//
//  Category.swift
//  Spotify
//
//  Created by user on 03/04/2021.
//

import Foundation

struct CategoryResponse: Codable {
    let categories: Item
    
    struct Item: Codable {
        let items: [Category]
    }
}

struct Category: Codable {
    let id: String
    let name: String
    let icons: [ImageModel]
}
