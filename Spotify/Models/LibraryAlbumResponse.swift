//
//  LibraryAlbumResponse.swift
//  Spotify
//
//  Created by user on 08/04/2021.
//

import Foundation

struct LibraryAlbumResponse: Codable {
    let items: [AlbumResponse]
    
    struct AlbumResponse: Codable{
        let album: Album
    }
}
