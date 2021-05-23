//
//  FavouriteRowImageView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-23.
//

import SwiftUI

struct FavouriteRowImageView: View {
    var image: UIImage
    var height: CGFloat
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: height)
            .clipped()
            .transition(
                .opacity.animation(.easeInOut(duration: 0.2))
            )
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    .listRowOverlayGradient.opacity(0.85),
                                    .listRowOverlayGradient.opacity(0)
                                ]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
    }
}
