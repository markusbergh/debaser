//
//  RowViewViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-01.
//

import UIKit
import Combine

class RowViewViewModel: ObservableObject {
    var cancellable: AnyCancellable? = nil
    var imageLoader = ImageLoader.shared
    
    @Published var image: UIImage = UIImage()
}

extension RowViewViewModel {
    func loadImage(with imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        
        if let data = imageLoader.cached(with: url as NSURL) {
            self.image = UIImage(data: data as Data)!
        
            return
        }
        
        cancellable = imageLoader.load(with: imageURL)
            .sink(receiveValue: { [weak self] data in
                guard let data = data else {
                    return
                }
                
                self?.image = UIImage(data: data)!
            })
    }
}
