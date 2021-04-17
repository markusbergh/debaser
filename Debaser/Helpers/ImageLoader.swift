//
//  ImageLoader.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-04.
//

import Foundation
import Combine

private let cache = NSCache<NSURL, NSData>()

final class ImageLoader {
    static let shared = ImageLoader()
    
    private let urlSession: URLSession
    
    private var isLoading = false
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func cached(with imageURL: NSURL) -> NSData? {
        return cache.object(forKey: imageURL) ?? nil
    }

    func load(with imageURL: String) -> AnyPublisher<Data?, Never> {
        isLoading = true
        
        // Check for url
        guard let url = URL(string: imageURL) else {
            isLoading = false
            
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .map { $0.data }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: {
                    cache.setObject($0! as NSData,
                                    forKey: url as NSURL)
                    
                    self.isLoading = false
                }
            )
            .eraseToAnyPublisher()
    }
}
