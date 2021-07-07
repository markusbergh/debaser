//
//  AppleMusicService.swift
//  AppleMusicService
//
//  Created by Markus Bergh on 2021-07-06.
//

import Combine
import Foundation
import StoreKit

public final class AppleMusicService {
    
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
    
    public static let shared = AppleMusicService()
    
    // MARK: Private
    
    private let appleMusicController = SKCloudServiceController()
    private let host = "api.music.apple.com"
    private lazy var storefrontId = "se"
    private var path: String {
        return "/v1/catalog/\(storefrontId)/search"
    }

    public enum AppleMusicServiceError: Error {
        case invalidURL
        case responseError
        case requestError(String)
    }

}

// MARK: - Search

extension AppleMusicService {
    
    private func makeURL(with searchTerm: String, byLimit limit: Int = 1) -> String? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        
        components.queryItems = [
            URLQueryItem(name: "term", value: searchTerm.replacingOccurrences(of: " ", with: "+")),
            URLQueryItem(name: "types", value: "songs"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        return components.url?.absoluteString
    }
    
    private func makeRequest(url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(AppleMusicService.developerToken)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
        
    public func search(for searchTerm: String) -> AnyPublisher<SongPreviews?, Error> {
        guard let urlString = makeURL(with: searchTerm) else {
            return Fail(error: AppleMusicServiceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        guard let requestURL = URL(string: urlString) else {
            return Fail(error: AppleMusicServiceError.invalidURL)
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
            .decode(type: SearchArtistResponse.self, decoder: JSONDecoder())
            .map { $0.results.songs.data.first?.attributes.previews.first }
            .eraseToAnyPublisher()
    }
    
}
