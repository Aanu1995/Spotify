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
    
    private static let baseAPIURL = "https://api.spotify.com/v1"
    
    private enum HttpMethod: String {
        case GET
        case POST
    }
    
    private enum ApiError: Error {
        case FailToGetData
    }
    
    // MARK: Endpoints
    
   private enum Endpoints {
        case currentProfileURL
        case newReleasesURL
        case featuredPlaylistsURL
        case recommendedGenreURL
        case recommendationURL(seeds: String)
        case albumDetailURL (id: String)
        case playlistDetailURL (id: String)
        case categoriesURL
        case categoryPlaylistsURL(id: String)
        case searchURL(query: String)
        
        var stringValue: String {
            switch self {
                case .currentProfileURL: return baseAPIURL + "/me"
                case .newReleasesURL: return baseAPIURL + "/browse/new-releases?limit=50"
                case .featuredPlaylistsURL: return baseAPIURL + "/browse/featured-playlists?limit=50"
                case .recommendedGenreURL: return baseAPIURL + "/recommendations/available-genre-seeds"
                case .recommendationURL(let seeds): return baseAPIURL + "/recommendations?limit=50&seed_genres=\(seeds)"
                case .albumDetailURL(let id): return baseAPIURL + "/albums/\(id)"
                case .playlistDetailURL(let id): return baseAPIURL + "/playlists/\(id)"
                case .categoriesURL: return baseAPIURL + "/browse/categories?limit=50"
                case .categoryPlaylistsURL(let id): return baseAPIURL + "/browse/categories/\(id)/playlists"
                case.searchURL(let query): return baseAPIURL + "/search?limit=50&q=\(query)&type=album,track,artist,playlist"
            }
        }
       
        var url: URL? {
            return URL(string: self.stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        }
    }
    
    // MARK: Album
    
    public func getNewReleases(completion: @escaping (Result<NewRelease, Error>) -> Void){
        createRequest(with: Endpoints.newReleasesURL.url, type: .GET) { (baseRequest) in
            guard let baseRequest = baseRequest else {
                return completion(.failure(ApiError.FailToGetData))
            }
            
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data else {
                    return completion(.failure(error!))
                }
                
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(NewRelease.self, from: data)
                    completion(.success(result))
                } catch {
                    return completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getAlbumDetail(album: Album, completion: @escaping (Result<AlbumDetailResponse, Error>) -> Void){
        createRequest(with: Endpoints.albumDetailURL(id: album.id).url, type: .GET) { (baseRequest) in
            guard let baseRequest = baseRequest else {
                return completion(.failure(ApiError.FailToGetData))
            }
            
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data else {
                    return completion(.failure(error!))
                }
                
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(AlbumDetailResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    return completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: Playlist
    
    public func getAllFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylist, Error>) -> Void){
        createRequest(with: Endpoints.featuredPlaylistsURL.url, type: .GET) { (baseRequest) in
            guard let baseRequest = baseRequest else {
                return completion(.failure(ApiError.FailToGetData))
            }
            
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data else {
                    return completion(.failure(error!))
                }
                
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(FeaturedPlaylist.self, from: data)
                    completion(.success(result))
                } catch {
                    return completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getPlaylistDetail (playlist: Playlist, completion: @escaping (Result<PlaylistDetailResponse, Error>) -> Void){
        createRequest(with: Endpoints.playlistDetailURL(id: playlist.id).url, type: .GET) { (baseRequest) in
            guard let baseRequest = baseRequest else {
                return completion(.failure(ApiError.FailToGetData))
            }
            
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data else {
                    return completion(.failure(error!))
                }
                
                let decoder = JSONDecoder()
                do {

                    let result = try decoder.decode(PlaylistDetailResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    return completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: Recommendations
    
    public func getRecommendedGenres(completion: @escaping (Result<RecommendedGenre, Error>) -> Void){
        createRequest(with: Endpoints.recommendedGenreURL.url, type: .GET) { (baseRequest) in
            guard let baseRequest = baseRequest else {
                return completion(.failure(ApiError.FailToGetData))
            }
            
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data else {
                    return completion(.failure(error!))
                }
                
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(RecommendedGenre.self, from: data)
                    completion(.success(result))
                } catch {
                    return completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    public func getRecommendations(genres: Set<String>,completion: @escaping (Result<Recommendation, Error>) -> Void){
        let seeds = genres.joined(separator: ",")
        createRequest(with: Endpoints.recommendationURL(seeds: seeds).url, type: .GET) { (baseRequest) in
            guard let baseRequest = baseRequest else {
                return completion(.failure(ApiError.FailToGetData))
            }
            
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data else {
                    return completion(.failure(error!))
                }
                
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(Recommendation.self, from: data)
                    completion(.success(result))
                } catch {
                    return completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: Categories
    
    public func getCategories(completion: @escaping (Result<CategoryResponse, Error>) -> Void){
        createRequest(with: Endpoints.categoriesURL.url, type: .GET) { (baseRequest) in
            guard let baseRequest = baseRequest else {
                return completion(.failure(ApiError.FailToGetData))
            }
            
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data else {
                    return completion(.failure(error!))
                }
                
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(CategoryResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    return completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getCategoryPlaylists(category id: String, completion: @escaping (Result<FeaturedPlaylist, Error>) -> Void){
        createRequest(with: Endpoints.categoryPlaylistsURL(id: id).url, type: .GET) { (baseRequest) in
            guard let baseRequest = baseRequest else {
                return completion(.failure(ApiError.FailToGetData))
            }
            
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data else {
                    return completion(.failure(error!))
                }
                
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(FeaturedPlaylist.self, from: data)
                    completion(.success(result))
                } catch {
                    return completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: Search
    
    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void){
        
        createRequest(with: Endpoints.searchURL(query: query).url, type: .GET) { (baseRequest) in
            guard let baseRequest = baseRequest else {
                return completion(.failure(ApiError.FailToGetData))
            }
            
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data else {
                    return completion(.failure(error!))
                }
                
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(SearchResultResponse.self, from: data)
                    var searchResults: [SearchResult] = []
                    
                    if !result.tracks.items.isEmpty {
                        searchResults.append(.track(model: result.tracks.items))
                    }
                    if !result.artists.items.isEmpty {
                        searchResults.append(.artist(model: result.artists.items))
                    }
                    if !result.playlists.items.isEmpty {
                        searchResults.append(.playlist(model: result.playlists.items))
                    }
                    if !result.albums.items.isEmpty {
                        searchResults.append(.album(model: result.albums.items))
                    }
                    completion(.success(searchResults))
                } catch {
                    return completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    // MARK: Profile
    
    // Get all the latest album releases
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        
        createRequest(with: Endpoints.currentProfileURL.url, type: .GET) { (baseRequest) in
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
