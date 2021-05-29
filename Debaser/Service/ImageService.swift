//
//  ImageService.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-04.
//

import Foundation
import Combine

private let cache = NSCache<NSURL, NSData>()

final class ImageService {
    static let shared = ImageService()
    
    // MARK: Private
    
    private let urlSession: URLSession
    private var isLoading = false
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    ///
    /// Returns cached image if available
    ///
    /// - parameter imageURL: The image url to search in cache for
    /// - returns: Data if image was found in cache
    ///
    func cached(with imageURL: NSURL) -> NSData? {
        return cache.object(forKey: imageURL) ?? nil
    }

    ///
    /// Returns a data task publisher to load an external
    ///
    /// - parameter imageURL: The image url to load data from
    /// - returns: A publisher that outputs optional data
    ///
    func load(with imageURL: String) -> AnyPublisher<Data?, Never> {
        isLoading = true
        
        // Check for url
        guard let url = URL(string: imageURL) else {
            isLoading = false
            
            return Empty().eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .map { $0.data }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [weak self] in
                    cache.setObject($0! as NSData, forKey: url as NSURL)
                    
                    self?.isLoading = false
                }
            )
            .eraseToAnyPublisher()
    }
}
