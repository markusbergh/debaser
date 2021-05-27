//
//  ImageViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-01.
//

import UIKit
import Combine

class ImageViewModel: ObservableObject {
    private var cancellable: AnyCancellable? = nil

    var imageService: ImageService?
    
    @Published var image: UIImage = UIImage()
    @Published var isLoaded: Bool = false
    
    init(with imageService: ImageService = ImageService.shared) {
        self.imageService = imageService
    }
}

extension ImageViewModel {
    func loadImage(with imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        guard let imageService = imageService else { return }

        if let data = imageService.cached(with: url as NSURL) {
            DispatchQueue.main.async {
                self.image = UIImage(data: data as Data)!
                self.isLoaded = true
            }
        
            return
        }
        
        cancellable = imageService.load(with: imageURL)
            .sink(receiveValue: { [weak self] data in
                guard let data = data else {
                    return
                }
                
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        self?.image = image
                        self?.isLoaded = true
                    }
                }
            })
    }
}
