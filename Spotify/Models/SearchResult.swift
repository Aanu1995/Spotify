//
//  SearchResult.swift
//  Spotify
//
//  Created by user on 03/04/2021.
//

import Foundation

enum SearchResult {
    case album(model: [Album])
    case artist(model: [Artist])
    case playlist(model: [Playlist])
    case track(model: [AudioTrack])
    
    var title: String {
        switch self {
        case .album:
            return "Albums"
        case .artist:
            return "Artists"
        case .playlist:
            return "Playlists"
        case .track:
            return "Songs"
        }
    }
}
