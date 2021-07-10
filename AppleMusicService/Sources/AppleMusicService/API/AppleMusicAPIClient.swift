//
//  AppleMusicAPIClient.swift
//  
//
//  Created by Markus Bergh on 2021-07-08.
//

import Combine
import Foundation
import StoreKit

class AppleMusicAPIClient {
    
    // MARK: Static
    
    static var developerToken: String {
        guard let infoDictPath = Bundle.main.path(forResource: "Debaser", ofType: "plist"),
              let infoDict = NSDictionary(contentsOfFile: infoDictPath) as? [String: Any] else {
            fatalError("Found no property list for api")
        }
        
        guard let token = infoDict["kAppleMusicToken"] as? String else {
            fatalError("There must be a token in property list")
        }
        
        return token
    }
    
    // MARK: Private
    
    private let appleMusicController = SKCloudServiceController()
    private let host = "api.music.apple.com"
    private lazy var storefrontId = "se"
    private var path: String {
        return "/v1/catalog/\(storefrontId)/search"
    }
    
}

// MARK: - Network

extension AppleMusicAPIClient {
    
    private func makeURL(with searchTerm: String, byLimit limit: Int = 1, withType type: AppleMusicSearchTypes = .songs) -> String? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        
        components.queryItems = [
            URLQueryItem(name: "term", value: searchTerm.replacingOccurrences(of: " ", with: "+")),
            URLQueryItem(name: "types", value: type.rawValue),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        return components.url?.absoluteString
    }
    
    private func makeRequest(url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(AppleMusicAPIClient.developerToken)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
}

// MARK: - Search

extension AppleMusicAPIClient {
    
    private func search(for searchTerm: String, byType type: AppleMusicSearchTypes) -> AnyPublisher<Data, Error> {
        guard let urlString = makeURL(with: searchTerm, withType: type) else {
            return Fail(error: AppleMusicServiceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        guard let requestURL = URL(string: urlString) else {
            return Fail(error: AppleMusicServiceError.requestError)
                .eraseToAnyPublisher()
        }
        
        let searchRequest = makeRequest(url: requestURL)
        
        return URLSession.shared.dataTaskPublisher(for: searchRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw AppleMusicServiceError.responseError
                }
                
                return data
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Queries

extension AppleMusicAPIClient {
    
    func songAttributes(for searchTerm: String) -> AnyPublisher<SongAttributes?, Error> {
        return search(for: searchTerm, byType: .songs)
            .decode(type: SearchArtistResponse.self, decoder: JSONDecoder())
            .map { $0.results.songs.data.first?.attributes }
            .eraseToAnyPublisher()
    }
    
    func musicPlayParams(for searchTerm: String) -> AnyPublisher<String?, Error> {
        return search(for: searchTerm, byType: .songs)
            .decode(type: SearchArtistResponse.self, decoder: JSONDecoder())
            .map { $0.results.songs.data.first?.attributes.playParams.id }
            .eraseToAnyPublisher()
    }
    
}
