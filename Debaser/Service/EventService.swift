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
    
    // MARK: Static
    
    static var baseUrl: String {
        guard let infoDictPath = Bundle.main.path(forResource: "Debaser", ofType: "plist"),
              let infoDict = NSDictionary(contentsOfFile: infoDictPath) as? [String: Any] else {
            fatalError("Found no property list for api")
        }
        
        guard let baseURL = infoDict["kDebaserApiURL"] else {
            fatalError("There must be an url in property list")
        }
        
        return "\(baseURL)/?version=2&method=getevents&format=json"
    }
    
    static let shared = EventService()
    
    // MARK: Private
    
    private var timeout: Timer?
    private var cancellable: AnyCancellable?
        
    init(timeout: Timer? = nil, cancellable: AnyCancellable? = nil) {
        self.timeout = timeout
        self.cancellable = cancellable
    }
}

// MARK: - Timeout

extension EventService {
    
    /// Sets a timeout for request
    private func timeoutForRequest(completion: @escaping () -> Void) {
        timeout?.invalidate()
        timeout = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            completion()
        }
    }
    
}

// MARK: - Data handlers

extension EventService {
    
    ///
    /// Get a data task publisher to request events from date range
    ///
    /// - parameters:
    ///   - from: Starting date string
    ///   - to: Ending date string
    /// - returns: A publisher that outputs a list of events
    ///
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
    
    ///
    /// Request events from date range
    ///
    /// - parameters:
    ///   - from: Starting date string
    ///   - to: Ending date string
    ///   - completion: A closure to call when the request has changed
    ///   - result: The request result
    ///
    func getEvents(fromDate from: String,
                   toDate to: String,
                   completion: @escaping (_ result: Result<[EventViewModel], ServiceError>) -> Void) {
        
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
    
    ///
    /// Request data from url
    ///
    /// - parameters:
    ///   - url: The url to reqest from
    ///   - completion: A closure to call when the request has changed
    ///   - result: The request result
    ///
    func getRequestWith(url: URL, _ completion: @escaping (_ result: Result<[Event], ServiceError>) -> Void) {
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
