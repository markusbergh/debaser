//
//  FavouriteRowImageView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-05-23.
//

import SwiftUI

struct FavouriteRowImageView: View {
    
    // MARK: Public
    
    let imageURL: String
    let height: CGFloat

    var overlayGradient: some View {
        return Rectangle()
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
    }
    
    var body: some View {
        AsyncImage(
            url: URL(string: imageURL),
            transaction: Transaction(animation: .easeOut(duration: 0.25))
        ) { phase in
            
            switch phase {
            case .empty:
                EmptyView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: height)
                    .clipped()
                    .transition(
                        .opacity.animation(.linear(duration: 0.25))
                    )
                    .overlay(overlayGradient)
            case .failure:
                Image(systemName: "photo")
            @unknown default:
                // Handle all other cases that might be added in the future
                EmptyView()
            }
        }
    }
}
