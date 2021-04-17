//
//  DetailViewViewModel.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-09.
//

import Combine
import SwiftUI

class DetailViewViewModel: ObservableObject {
    var cancellable: AnyCancellable? = nil
    var imageLoader = ImageLoader()
    
    @Published var image: UIImage = UIImage()
}

extension DetailViewViewModel {
    func loadImage(with imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        
        if let data = imageLoader.cached(with: url as NSURL) {
            self.image = UIImage(data: data as Data)!
        
            return
        }
        
        cancellable = imageLoader.load(with: imageURL)
            .sink(receiveValue: { data in
                guard let data = data else {
                    return
                }
                
                self.image = UIImage(data: data)!
            })
    }
}
