//
//  DetailTopImageView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-15.
//

import SwiftUI

struct DetailTopImageView: View {

    /// Image url to load
    let imageURL: String
    
    var body: some View {
        GeometryReader { geometry -> DetailImageView in
            var width =  geometry.size.width
            var height = geometry.size.height + geometry.frame(in: .global).minY
            var offsetY = -geometry.frame(in: .global).minY
            
            if geometry.frame(in: .global).minY <= 0 {
                width = geometry.size.width
                height = geometry.size.height
                offsetY = -geometry.frame(in: .global).minY / 3
            }
            
            return DetailImageView(
                imageURL: imageURL,
                width: width,
                height: height,
                offset: offsetY
            )
        }
        .frame(height: 300)
    }
}

struct DetailImageView: View {
    
    /// Image url to load
    let imageURL: String
    
    /// Image width
    let width: CGFloat
    
    /// Image height
    let height: CGFloat
    
    /// Offset based on scroll
    let offset: CGFloat
        
    var body: some View {
        AsyncImage(
            url: URL(string: imageURL),
            transaction: Transaction(animation: .easeOut(duration: 0.5))
        ) { phase in
            switch phase {
            case .empty:
                // TODO: Handle pending phase
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .transition(
                        .scale(scale: 1.25, anchor: .center).combined(
                            with: .opacity
                        )
                    )
            case .failure:
                Image(systemName: "photo")
            @unknown default:
                // Handle all other cases that might be added in the future
                EmptyView()
            }
        }
       .mask(DetailImageMaskView())
       .offset(y: offset)
    }
}

struct DetailImageMaskView: View {
    
    /// Corner radius
    private let radius: CGFloat = 50.0
    
    /// Applied corners
    private let corners: UIRectCorner = [.bottomLeft, .bottomRight]
    
    var body: some View {
        Rectangle()
            .cornerRadius(radius, corners: corners)
    }
}

struct DetailImageView_Previews: PreviewProvider {
    static let image = UIImage(named: "EventImage")!
    
    static var previews: some View {
        DetailImageView(
            imageURL: "https://debaser.se/img/10982.jpg",
            width: 390,
            height: 250,
            offset: 0
        )
    }
}
