//
//  AuthResponse.swift
//  Spotify
//
//  Created by user on 26/03/2021.
//

import Foundation

struct AuthResponse: Codable {
    
    let accessToken: String
    let tokenType: String
    let refreshToken: String?
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
