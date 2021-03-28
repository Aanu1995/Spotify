//
//  ApiService.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import Foundation

class ApiService {
    static let shared = ApiService()
    
    private init() {}
    
    enum HttpMethod: String {
        case GET
        case POST
    }
    
    enum ApiError: Error {
        case FailToGetData
    }
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
        static let currentProfileURL = baseAPIURL + "/me"
    }
    
    func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        
        createRequest(with: URL(string: Constants.currentProfileURL), type: .GET) { (baseRequest) in
            guard let baseRequest = baseRequest else {
                return completion(.failure(ApiError.FailToGetData))
            }
            
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data else {
                    return completion(.failure(error!))
                }
                
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(UserProfile.self, from: data)
                    completion(.success(result))
                } catch {
                    return completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    private func createRequest(with url: URL?, type: HttpMethod, completion: @escaping (URLRequest?) -> Void) {
        guard let url = url else { return completion(nil) }

        AuthManager.shared.withValidToken { (token) in
            guard let token = token else { return completion(nil) }
            
            var request = URLRequest(url: url)
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            completion(request)
        }
    }
}
