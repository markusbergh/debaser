//
//  DetailSpotifyPlayerView.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-07-12.
//

import SwiftUI

struct DetailSpotifyPlayerView: View {
    @Environment(\.spotifyService) var spotifyService
    
    let songTitle: String
    let artistName: String
    let albumName: String
    let artworkURL: String?

    @Binding var isStreaming: Bool
    @State private var streamProgress: CGFloat = 0.0
    
    private var streamPositionDidUpdate: NotificationCenter.Publisher {
        return NotificationCenter.default.publisher(for: NSNotification.Name("spotifyStreamDidChangePosition"))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Detail.Preview.Artist")
                .font(Font.Variant.tiny.font)
                .fontWeight(.semibold)
            
            HStack(spacing: 15) {
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
                    .overlay(
                        isStreaming ?
                            AnyView(
                                DetailStreamProgress(streamProgress: streamProgress)
                                    .onReceive(streamPositionDidUpdate) { notification in
                                        guard let streamPositionObject = notification.object as? NSDictionary,
                                              let currentStreamPosition = streamPositionObject["current"] as? CGFloat else {
                                            return
                                        }
                                        
                                        // Update stream progress state
                                        streamProgress = currentStreamPosition / 100.0
                                    }
                            )
                        : AnyView(EmptyView())
                    )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(songTitle)
                        .font(.subheadline)
                        .lineLimit(2)
                    
                    Text(artistName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                                
                Spacer()

                Image("SpotifyIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
            }
        }
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

struct DetailSpotifyPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        DetailSpotifyPlayerView(
            songTitle: "Song title",
            artistName: "Artist name",
            albumName: "Album name",
            artworkURL: "",
            isStreaming: .constant(false)
        )
    }
}


