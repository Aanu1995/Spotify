//
//  SettingsModel.swift
//  Spotify
//
//  Created by user on 28/03/2021.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}


