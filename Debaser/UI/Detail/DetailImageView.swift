//
//  DetailImageView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-15.
//

import SwiftUI

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
