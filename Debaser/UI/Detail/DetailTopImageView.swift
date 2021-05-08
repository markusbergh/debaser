//
//  DetailTopImageView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-15.
//

import SwiftUI

struct DetailTopImageView: View {
    @EnvironmentObject var viewModel: ImageViewModel
    
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
                image: viewModel.image,
                width: width,
                height: height,
                offsetY: offsetY
            )
        }
        .frame(height: 300)
    }
}

struct DetailImageView: View {
    var image: UIImage
    var width: CGFloat
    var height: CGFloat
    var offsetY: CGFloat
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .mask(
                Rectangle()
                    .cornerRadius(50, corners: [.bottomLeft, .bottomRight])
            )
            .clipped()
            .offset(y: offsetY)
    }
}

struct DetailImageView_Previews: PreviewProvider {
    static var previews: some View {
        DetailImageView(
            image: UIImage(named: "EventImage")!,
            width: 390,
            height: 250,
            offsetY: 0
        )
    }
}
