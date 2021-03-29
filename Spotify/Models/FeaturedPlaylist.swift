//
//  FeaturedPlaylist.swift
//  Spotify
//
//  Created by user on 29/03/2021.
//

import Foundation

struct FeaturedPlaylist: Codable {
    let playlists: PlaylistResponse
    
    struct PlaylistResponse: Codable {
        let items: [Playlist]
    }
}


