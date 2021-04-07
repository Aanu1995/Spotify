//
//  AuthManager.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import Foundation

final class AuthManager {
    
    static let shared = AuthManager()
    
    private init () {}
    
    struct Constants {
        static let clientId = PrivateKeys.clientId
        static let clientSecret = PrivateKeys.clientSecret
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURL = "https://www.example.com"
    }
    
    public var signInURL: URL? {
        let baseURL = "https://accounts.spotify.com/authorize"
        let scopes = "user-read-private user-read-email user-library-read user-library-modify playlist-modify-public playlist-modify-private user-library-modify"
        let stringURL = "\(baseURL)?response_type=code&client_id=\(Constants.clientId)&scope=\(scopes)&redirect_uri=\(Constants.redirectURL)&show_dialog=TRUE"

        return URL(string: stringURL.replacingOccurrences(of: " ", with: "%20"))
    }
    
    var isSignedIn: Bool {
        return (accessToken != nil && userId != nil)
    }
    
    var userId: String? {
        return UserDefaults.standard.string(forKey: "userId")
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.value(forKey: "expiration_date") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let tokenExpirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= tokenExpirationDate
    }
    
    private func getToken(components: URLComponents, completionHandler: @escaping (Bool) -> Void) {
        let url = URL(string: Constants.tokenAPIURL)!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let basicToken = Constants.clientId + ":" + Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            completionHandler(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self]  (data, _, error) in
            guard let data = data else {
                completionHandler(false)
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode(AuthResponse.self, from: data)
                self?.cacheToken(response: result)
                // get userProfile and save the id to storage
                if let _ = result.refreshToken {
                    self?.getUserProfile(result: result, completionHandler: { status in
                        completionHandler(status)
                    })
                } else {
                    self?.cacheToken(response: result)
                    completionHandler(true)
                }
                
            } catch {
                completionHandler(false)
            }
        }
        task.resume()
    }
    
    public func exchangeCodeForToken (code: String, completionHandler: @escaping (Bool) -> Void){
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURL)
        ]
        getToken(components: components) { (success) in
            DispatchQueue.main.async {
                completionHandler(success)
            }
        }
    }
    
    private func getUserProfile (result: AuthResponse, completionHandler: @escaping (Bool) -> Void){
        ApiService.shared.getCurrentUserProfile { profileResult in
            switch profileResult {
            case .success:
                completionHandler(true)
            case .failure:
                completionHandler(false)
            }
        }
    }
    
    public func withValidToken (completion: @escaping (String?) -> Void){
        if shouldRefreshToken {
           
            self.refreshIfNeeded { [weak self] (success) in
                if success, let token = self?.accessToken {
                    completion(token)
                } else {
                    completion(nil)
                }
            }
        } else if let token = accessToken {
            completion(token)
        }
    }
    
    public func refreshIfNeeded(completionHandler: ((Bool) -> Void)?) {
        guard shouldRefreshToken else {
            completionHandler?(true)
            return
        }
        
        var components = URLComponents()
        
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: Constants.clientId)
        ]
        
        getToken(components: components) { (success) in
            DispatchQueue.main.async {
                completionHandler?(success)
            }
        }
    }
    
    private func cacheToken(response: AuthResponse) {
        UserDefaults.standard.setValue(response.accessToken, forKey: "access_token")
        if let refreshToken = response.refreshToken {
            UserDefaults.standard.setValue(refreshToken, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(response.expiresIn)), forKey: "expiration_date")
    }
    
    public func saveUserId(userId: String){
        UserDefaults.standard.setValue(userId, forKey: "userId")
    }
}
