//
//  DetailSpotifyPlayButtonView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-07-13.
//

import SwiftUI

struct DetailSpotifyPlayButtonView: View {
    @State private var streamProgress: CGFloat = 0.0
    
    private var streamPositionDidUpdate: NotificationCenter.Publisher {
        return NotificationCenter.default.publisher(for: NSNotification.Name("spotifyStreamDidChangePosition"))
    }
    
    @Binding var isStreaming: Bool
    let artworkURL: String?

    var body: some View {
        Button(action: {
            isStreaming.toggle()
            
            if isStreaming {
                streamProgress = 0.0
            }
        }) {
            Group {
                if let artworkURL = artworkURL {
                    DetailSpotifyArtworkView(artworkURL: artworkURL, isStreaming: isStreaming)
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 45, height: 45)
                }
            }
            .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 0)
            .overlay(
                Image(systemName: isStreaming ? "pause.fill" : "play.fill")
                    .resizable()
                    .foregroundColor(.green)
                    .frame(width: 11, height: 11)
                    .offset(x: isStreaming ? 0 : 2)
            )
            .if(isStreaming) { view in
                view.overlay(
                    DetailStreamProgress(streamProgress: streamProgress)
                        .onReceive(streamPositionDidUpdate) { notification in
                            handleStreamPositionDidUpdate(notification: notification)
                        }
                )
            }
        }
    }
    
    ///
    /// Handles an incoming stream of position updates
    ///
    /// - Parameter notification: The notification sent
    ///
    private func handleStreamPositionDidUpdate(notification: NotificationCenter.Publisher.Output) {
        guard let streamPositionObject = notification.object as? NSDictionary,
              let currentStreamPosition = streamPositionObject["current"] as? CGFloat else {
            return
        }
        
        // Update stream progress state
        streamProgress = currentStreamPosition / 100.0
    }
}

struct DetailSpotifyArtworkView: View {

    let artworkURL: String
    let isStreaming: Bool

    @StateObject private var imageViewModel = ImageViewModel()
    
    private var rotationAnimation: Animation {
        switch isStreaming {
        case true:
            return .linear(duration: 2).repeatForever(autoreverses: false)
        case false:
            return .default
        }
    }
    
    private var artworkImage: UIImage {
        return imageViewModel.isLoaded ? imageViewModel.image : UIImage()
    }
    
    var body: some View {
        Image(uiImage: artworkImage)
            .resizable()
            .scaledToFill()
            .frame(width: 45, height: 45)
            .onAppear {
                imageViewModel.load(with: artworkURL)
            }
            .clipShape(Circle())
            .rotationEffect(.degrees(isStreaming ? 360 : 0))
            .animation(rotationAnimation, value: isStreaming)
            .overlay(
                Circle().fill(
                    Color.white.opacity(0.5)
                )
            )
    }
}
