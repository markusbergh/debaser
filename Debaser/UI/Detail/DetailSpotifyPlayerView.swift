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
    let artwork: String

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
            
            HStack(spacing: 10) {
                Button(action: {
                    isStreaming.toggle()
                    
                    if isStreaming {
                        streamProgress = 0.0
                    }
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                        .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 0)
                        .overlay(
                            Image(systemName: isStreaming ? "pause.fill" : "play.fill")
                                .resizable()
                                .foregroundColor(.green)
                                .frame(width: 11, height: 11)
                                .offset(x: isStreaming ? 0 : 2)
                                .animation(nil, value: streamProgress > 0.0)
                        )
                        .overlay(
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
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(songTitle)
                        .font(.subheadline)
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

struct DetailSpotifyPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        DetailSpotifyPlayerView(
            songTitle: "Song title",
            artistName: "Artist name",
            albumName: "Album name",
            artwork: "",
            isStreaming: .constant(false)
        )
    }
}


