//
//  EventService.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

import Foundation

enum ServiceError: Error {
    case invalidURL
    case unknownError
    case decodingError
    
    var description: String {
        switch self {
        case .unknownError:
            return "Unknown error"
        case .invalidURL:
            return "The URL was invalid"
        case .decodingError:
            return "There was an error while decoding"
        }
    }
}

final class EventService {
    static let baseUrl = "https://debaser.se/debaser/api/?version=2&method=getevents&format=json"
    
    func getEvents(fromDate from: String,
                   toDate to: String,
                   completion: @escaping (Result<[Event], ServiceError>) -> Void) {
        
        guard var urlComponents = URLComponents(string: EventService.baseUrl) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from", value: from))
        queryItems.append(URLQueryItem(name: "to", value: to))
        
        urlComponents.queryItems = queryItems

        guard let urlString = urlComponents.string, let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.unknownError))
                return
            }
            
            do {
                let events = try JSONDecoder().decode([Event].self, from: data)
                completion(.success(events))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
