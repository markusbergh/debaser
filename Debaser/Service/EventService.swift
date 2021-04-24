//
//  EventService.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-24.
//

import Foundation
import Combine

enum ServiceError: Error {
    case invalidURL
    case unknownError
    case decodingError
    case timeout
    case responseError
    
    var description: String {
        switch self {
        case .responseError:
            return "Response error"
        case .unknownError:
            return "Unknown error"
        case .invalidURL:
            return "The URL was invalid"
        case .decodingError:
            return "There was an error while decoding"
        case .timeout:
            return "The request timed out"
        }
    }
}

final class EventService {
    static let baseUrl = "https://debaser.se/debaser/api/?version=2&method=getevents&format=json"
    
    private var timeout: Timer?
    private var cancellable: AnyCancellable?
    
    private func timeoutForRequest(completion: @escaping () -> Void) {
        timeout?.invalidate()
        timeout = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            completion()
        }
    }
    
    func getPublisher(fromDate from: String, toDate to: String) -> AnyPublisher<[EventViewModel], ServiceError> {
        guard var urlComponents = URLComponents(string: EventService.baseUrl) else {
            return Fail(error: ServiceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        timeoutForRequest(completion: { [weak self] in
            // Cancel any publisher
            self?.cancellable?.cancel()
            
            // TODO: Send .timeout
        })
        
        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from", value: from))
        queryItems.append(URLQueryItem(name: "to", value: to))
        
        urlComponents.queryItems = queryItems

        guard let urlString = urlComponents.string, let url = URL(string: urlString) else {
            return Fail(error: ServiceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw ServiceError.responseError
                }
                
                return data
            }
            .decode(type: [Event].self, decoder: JSONDecoder())
            .mapError { error in
                switch error {
                case is Decodable:
                    return ServiceError.decodingError
                default:
                    return ServiceError.unknownError
                }
            }
            .map { events in
                self.timeout?.invalidate()
                
                var list = [EventViewModel]()
                
                for event in events {
                    list.append(EventViewModel(with: event))
                }
                
                return list
            }
            .eraseToAnyPublisher()
    }
    
    func getEvents(fromDate from: String,
                   toDate to: String,
                   completion: @escaping (Result<[EventViewModel], ServiceError>) -> Void) {
        
        guard var urlComponents = URLComponents(string: EventService.baseUrl) else {
            completion(.failure(.invalidURL))
            return
        }
        
        timeoutForRequest(completion: { [weak self] in
            // Cancel any publisher
            self?.cancellable?.cancel()
            
            // Send failure
            completion(.failure(.timeout))
        })
        
        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from", value: from))
        queryItems.append(URLQueryItem(name: "to", value: to))
        
        urlComponents.queryItems = queryItems

        guard let urlString = urlComponents.string, let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw ServiceError.responseError
                }
                
                return data
            }
            .decode(type: [Event].self, decoder: JSONDecoder())
            // Must define return type (ServiceError), otherwise a build error...
            .mapError { error -> ServiceError in
                switch error {
                case is Decodable:
                    return ServiceError.decodingError
                default:
                    return ServiceError.unknownError
                }
            }
            .sink(receiveCompletion: { result in
                self.timeout?.invalidate()
                
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                break
                case .finished:
                    // All is good...
                    break
                }
             }, receiveValue: { events in
                self.timeout?.invalidate()
                
                var list = [EventViewModel]()
                
                for event in events {
                    list.append(EventViewModel(with: event))
                }
                
                completion(.success(list))
            })
    }
    
    func getRequestWith(url: URL, completion: @escaping (Result<[Event], ServiceError>) -> Void) {
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
