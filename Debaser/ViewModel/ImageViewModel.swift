//
//  ImageViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-01.
//

import UIKit
import Combine

class ImageViewModel: ObservableObject {
    var cancellable: AnyCancellable? = nil
    var imageLoader = ImageLoader.shared
    
    @Published var image: UIImage = UIImage()
    @Published var isLoaded: Bool = false
}

extension ImageViewModel {
    func loadImage(with imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        
        if let data = imageLoader.cached(with: url as NSURL) {
            image = UIImage(data: data as Data)!
            isLoaded = true
        
            return
        }
        
        cancellable = imageLoader.load(with: imageURL)
            .sink(receiveValue: { [weak self] data in
                guard let data = data else {
                    return
                }
                
                if let image = UIImage(data: data) {
                    self?.image = image
                    self?.isLoaded = true
                }
            })
    }
}
